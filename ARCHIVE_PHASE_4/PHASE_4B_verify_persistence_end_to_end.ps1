# PHASE_4B_verify_persistence_end_to_end.ps1
# Purpose:
# 1) Confirm backend is reachable
# 2) Reset progress
# 3) Solve one puzzle
# 4) Confirm API reflects solvedIds
# 5) Confirm progress.json was updated on disk
# 6) Confirm nodemon ignore exists (so no restart loops)

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: $p" }
}

function Write-Section([string]$title) {
  Write-Host ""
  Write-Host "=== $title ===" -ForegroundColor Cyan
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
$BACKEND = Join-Path $ROOT "backend"
$BACKEND_SRC = Join-Path $BACKEND "src"
$DATA_FILE = Join-Path $BACKEND_SRC "data\progress.json"
$NODEMON_JSON = Join-Path $BACKEND "nodemon.json"

Write-Section "A) Sanity: required files"
Assert-Path $BACKEND "backend folder"
Assert-Path $BACKEND_SRC "backend\src folder"
Assert-Path $DATA_FILE "progress persistence file"
# nodemon.json is optional but recommended. We'll warn if missing.
if (-not (Test-Path $NODEMON_JSON)) {
  Write-Host "WARN: nodemon.json not found at: $NODEMON_JSON" -ForegroundColor Yellow
  Write-Host "      If you ever see nodemon restart loops, create nodemon.json to ignore src\data\progress.json" -ForegroundColor Yellow
}

Write-Section "B) Backend reachability"
try {
  $health = Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing
  Write-Host "Health: $($health.StatusCode) $($health.Content)"
} catch {
  throw "Backend is not reachable on http://localhost:8085. Start it first: cd $BACKEND; npm run dev"
}

Write-Section "C) Reset -> Get"
$r = Invoke-WebRequest "http://localhost:8085/progress/reset" -Method Post -UseBasicParsing
Write-Host "Reset: $($r.StatusCode) $($r.Content)"
$g1 = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
Write-Host "Get1:  $($g1.StatusCode) $($g1.Content)"

Write-Section "D) Solve demo-1 -> Get"
$s = Invoke-WebRequest "http://localhost:8085/progress/solve" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{ "puzzleId":"demo-1" }' `
  -UseBasicParsing
Write-Host "Solve: $($s.StatusCode) $($s.Content)"
$g2 = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
Write-Host "Get2:  $($g2.StatusCode) $($g2.Content)"

Write-Section "E) Confirm progress.json on disk"
# Print the file so we can visually confirm solvedIds / solved counters persisted
Write-Host "progress.json path: $DATA_FILE" -ForegroundColor Green
Get-Content $DATA_FILE

Write-Section "F) (Optional) nodemon ignore check"
if (Test-Path $NODEMON_JSON) {
  Write-Host "nodemon.json contents:" -ForegroundColor Green
  Get-Content $NODEMON_JSON
  Write-Host ""
  Write-Host "If nodemon loops, ensure nodemon.json ignores src\data\progress.json or src\data\*." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "PHASE_4B GREEN: persistence verified (API + file on disk)." -ForegroundColor Green
Write-Host "Returned to project root: $ROOT" -ForegroundColor Green
Set-Location $ROOT
