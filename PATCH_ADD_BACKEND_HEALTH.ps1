# PATCH_ADD_BACKEND_HEALTH.ps1
# Adds GET /health to backend/src/server.cjs
# Golden Rules: backup-first, stop-on-mismatch, no guessing.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host "OK: $msg" -ForegroundColor Green }

$FILE = "C:\Projects\MindLab_Starter_Project\backend\src\server.cjs"
if (-not (Test-Path $FILE)) { Fail "Target not found: $FILE" }

# Backup
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$FILE.bak_$ts"
Copy-Item $FILE $bak -Force
Ok "Backup created: $bak"

$content = Get-Content $FILE -Raw

# If already present, do nothing (idempotent)
if ($content -match '(?m)app\.get\(\s*["'']\/health["'']') {
  Ok "Route /health already exists. No changes made."
  exit 0
}

# Anchor: insert before /puzzles route (must exist)
$anchorPattern = '(?m)^\s*app\.get\(\s*["'']\/puzzles["'']'
if ($content -notmatch $anchorPattern) {
  Fail "Could not find anchor route app.get('/puzzles') in server.cjs. Aborting (no guessing)."
}

$healthBlock = @"
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

"@

# Insert healthBlock immediately before the first /puzzles route
$content2 = [regex]::Replace($content, $anchorPattern, ($healthBlock + '$0'), 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok "Inserted GET /health before /puzzles."
Ok "Patch completed successfully."
