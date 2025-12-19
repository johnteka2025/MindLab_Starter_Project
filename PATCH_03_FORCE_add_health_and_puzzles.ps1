# PATCH_03_FORCE_add_health_and_puzzles.ps1
$server = "C:\Projects\MindLab_Starter_Project\backend\src\server.cjs"
if (-not (Test-Path $server)) { throw "Missing: $server" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$server.bak_force_health_puzzles_$stamp"
Copy-Item -Force $server $bak
Write-Host "Backup created: $bak" -ForegroundColor Green

$txt = Get-Content -Raw -Encoding UTF8 $server

# Ensure we can find the app creation line
$pattern = "(?im)^\s*(const|let|var)\s+app\s*=\s*express\(\)\s*;\s*$"
if ($txt -notmatch $pattern) {
  throw "Could not find 'const app = express();' in $server"
}

# If routes already exist (real handlers), do nothing. We check for function bodies, not mere strings.
$hasHealthHandler  = ($txt -match "(?is)app\.get\(\s*['""]/health['""]\s*,\s*\(?\s*(req|_req)\s*,\s*(res|_res)\s*\)?\s*=>")
$hasPuzzlesHandler = ($txt -match "(?is)app\.get\(\s*['""]/puzzles['""]\s*,\s*\(?\s*(req|_req)\s*,\s*(res|_res)\s*\)?\s*=>")

if ($hasHealthHandler -and $hasPuzzlesHandler) {
  Write-Host "Real /health and /puzzles handlers already present. No changes applied." -ForegroundColor Yellow
  exit 0
}

$block = @"
`n// ---- FORCE-ADDED baseline endpoints (health + puzzles) ----
const __PUZZLES = [
  { id: 1, question: "What is 2 + 2?", options: ["3","4","5"], correctIndex: 1 },
  { id: 2, question: "What is the color of the sky?", options: ["Blue","Green","Red"], correctIndex: 0 }
];

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/puzzles', (req, res) => {
  res.json(__PUZZLES);
});

// Make puzzles visible to other modules if they want it
try { app.locals.puzzles = __PUZZLES; } catch (_) {}
// ---- END FORCE-ADDED baseline endpoints ----
`n
"@

# Insert immediately after app creation line
$txt2 = [regex]::Replace($txt, $pattern, { param($m) $m.Value + $block }, 1)
Set-Content -Encoding UTF8 -Path $server -Value $txt2
Write-Host "Inserted FORCE baseline endpoints into server.cjs" -ForegroundColor Green

# Syntax check
cd C:\Projects\MindLab_Starter_Project\backend
node --check .\src\server.cjs
if ($LASTEXITCODE -ne 0) { throw "Syntax check FAILED after PATCH_03." }
Write-Host "Syntax check OK after PATCH_03." -ForegroundColor Green
