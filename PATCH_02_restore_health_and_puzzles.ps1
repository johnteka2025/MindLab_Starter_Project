# PATCH_02_restore_health_and_puzzles.ps1
$server = "C:\Projects\MindLab_Starter_Project\backend\src\server.cjs"
if (-not (Test-Path $server)) { throw "Missing: $server" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item -Force $server "$server.bak_restore_routes_$stamp"
Write-Host "Backup created: $server.bak_restore_routes_$stamp" -ForegroundColor Green

$txt = Get-Content -Raw -Encoding UTF8 $server

$needsHealth = ($txt -notmatch "(?im)['""]?/health['""]?")
$needsPuzzles = ($txt -notmatch "(?im)['""]?/puzzles['""]?")

if (-not $needsHealth -and -not $needsPuzzles) {
  Write-Host "server.cjs already appears to contain /health and /puzzles. No patch applied." -ForegroundColor Yellow
} else {
  $routes = @"
`n// ---- Restored baseline endpoints (health + puzzles) ----
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

// Optional: allow other modules to read puzzles count safely
try { app.locals.puzzles = __PUZZLES; } catch (_) {}
// ---- End restored endpoints ----
`n
"@

  # Insert after app creation
  $pattern = "(?im)^\s*(const|let|var)\s+app\s*=\s*express\(\)\s*;\s*$"
  if ($txt -notmatch $pattern) { throw "Could not find 'const app = express();' in server.cjs" }

  $txt = [regex]::Replace($txt, $pattern, { param($m) $m.Value + $routes }, 1)
  Set-Content -Encoding UTF8 -Path $server -Value $txt
  Write-Host "Patched server.cjs with restored /health and /puzzles + app.locals.puzzles" -ForegroundColor Green
}

cd C:\Projects\MindLab_Starter_Project\backend
node --check .\src\server.cjs
if ($LASTEXITCODE -ne 0) { throw "Syntax check FAILED after restoring routes." }
Write-Host "Syntax check OK." -ForegroundColor Green
