# PATCH_10_backend_baseline_endpoints_SERVER_CJS.ps1
$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$server = Join-Path $root "backend\src\server.cjs"
if (-not (Test-Path $server)) { throw "Missing: $server" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$server.bak_baseline_$stamp"
Copy-Item -Force $server $bak
Write-Host "Backup created: $bak" -ForegroundColor Green

$c = Get-Content $server -Raw

# Ensure express app exists (we won't rewrite structure, only insert safe blocks if missing)
if ($c -notmatch "express\(") {
  throw "server.cjs does not look like an Express server (missing express()). Aborting for safety."
}

# 1) Add /_runtime (optional) if missing
if ($c -notmatch "app\.get\(\s*['""]/_runtime['""]") {
  $block = @"
`n// --- runtime fingerprint (added by PATCH_10) ---
app.get("/_runtime", (req, res) => {
  res.json({
    file: "backend/src/server.cjs",
    pid: process.pid,
    node: process.version,
    time: new Date().toISOString(),
  });
});
"@
  # Insert after app creation if possible
  if ($c -match "const\s+app\s*=\s*express\(\)\s*;?") {
    $c = $c -replace "(const\s+app\s*=\s*express\(\)\s*;?)", "`$1$block"
  } else {
    # fallback: append near top
    $c = $c + $block
  }
  Write-Host "Inserted /_runtime endpoint." -ForegroundColor Green
} else {
  Write-Host "/_runtime already present." -ForegroundColor DarkGreen
}

# 2) Ensure /health exists
if ($c -notmatch "app\.get\(\s*['""]/health['""]") {
  $health = @"
`n// --- health (added by PATCH_10) ---
app.get("/health", (req, res) => res.json({ ok: true }));
"@
  $c = $c + $health
  Write-Host "Inserted /health endpoint." -ForegroundColor Green
} else {
  Write-Host "/health already present." -ForegroundColor DarkGreen
}

# 3) Ensure /puzzles exists (very lightweight fallback if missing)
if ($c -notmatch "app\.get\(\s*['""]/puzzles['""]") {
  $puzzles = @"
`n// --- puzzles fallback (added by PATCH_10) ---
app.get("/puzzles", (req, res) => {
  res.json([
    { id: 1, question: "What is 2 + 2?", options: ["3","4","5"], correctIndex: 1 },
    { id: 2, question: "What is the color of the sky?", options: ["Blue","Green","Red"], correctIndex: 0 }
  ]);
});
"@
  $c = $c + $puzzles
  Write-Host "Inserted /puzzles fallback endpoint." -ForegroundColor Green
} else {
  Write-Host "/puzzles already present." -ForegroundColor DarkGreen
}

# 4) Ensure /progress exists (do not override your real implementation; only add if missing)
if ($c -notmatch "app\.(get|post)\(\s*['""]/progress['""]") {
  $progress = @"
`n// --- progress fallback (added by PATCH_10) ---
let __progress = { total: 2, solved: 0 };
app.get("/progress", (req, res) => res.json(__progress));
app.post("/progress", (req, res) => {
  const body = req.body || {};
  if (body.correct === true) {
    __progress.solved = Math.min(__progress.total, (__progress.solved || 0) + 1);
  }
  res.json(__progress);
});
"@
  $c = $c + $progress
  Write-Host "Inserted /progress fallback endpoint." -ForegroundColor Green
} else {
  Write-Host "/progress already present (not touching)." -ForegroundColor DarkGreen
}

Set-Content -Encoding UTF8 $server -Value $c
Write-Host "Patched: $server" -ForegroundColor Green

# Syntax check
Push-Location (Join-Path $root "backend")
node --check ".\src\server.cjs"
if ($LASTEXITCODE -ne 0) { throw "Node syntax check FAILED for server.cjs" }
Pop-Location
Write-Host "Syntax check OK." -ForegroundColor Green

Write-Host "`nNEXT:" -ForegroundColor Yellow
Write-Host "1) Restart backend + frontend clean (use RESET script in Step 4 below)." -ForegroundColor Yellow
Write-Host "2) Verify endpoints: /health /puzzles /progress /_runtime" -ForegroundColor Yellow
