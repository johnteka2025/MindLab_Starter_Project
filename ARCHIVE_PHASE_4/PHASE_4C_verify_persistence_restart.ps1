# PHASE_4C_verify_persistence_restart.ps1
$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: $p" }
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
$PROGRESS_FILE = Join-Path $ROOT "backend\src\data\progress.json"

try {
  cd $ROOT

  Write-Host "=== PHASE 4C: Verify persistence to disk + survives restart ===" -ForegroundColor Cyan
  Assert-Path $PROGRESS_FILE "progress.json"

  # 1) Reset -> Solve -> Confirm API
  Write-Host "`n--- A) API reset ---" -ForegroundColor Cyan
  Invoke-WebRequest "http://localhost:8085/progress/reset" -Method Post -UseBasicParsing | Out-Null
  $p1 = (Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing).Content
  Write-Host "API after reset: $p1" -ForegroundColor Green

  Write-Host "`n--- B) API solve demo-1 ---" -ForegroundColor Cyan
  Invoke-WebRequest "http://localhost:8085/progress/solve" -Method Post -ContentType "application/json" -Body '{ "puzzleId":"demo-1" }' -UseBasicParsing | Out-Null
  $p2 = (Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing).Content
  Write-Host "API after solve: $p2" -ForegroundColor Green

  # 2) Confirm disk file updated
  Write-Host "`n--- C) Disk file after solve ---" -ForegroundColor Cyan
  Write-Host "File: $PROGRESS_FILE" -ForegroundColor DarkGray
  $disk = Get-Content $PROGRESS_FILE -Raw
  Write-Host $disk

  # Lightweight sanity: ensure demo-1 appears somewhere in the persisted JSON
  if ($disk -notmatch "demo-1") {
    Write-Host "`nWARNING: demo-1 not found in progress.json. Persistence write may not be firing." -ForegroundColor Yellow
    Write-Host "Next: we'll patch progressPersistence write() call location." -ForegroundColor Yellow
  } else {
    Write-Host "`nPHASE 4C (Disk) looks good: demo-1 is persisted." -ForegroundColor Green
  }

  Write-Host "`n--- D) Restart test (manual) ---" -ForegroundColor Cyan
  Write-Host "1) In the backend terminal, press Ctrl+C to stop nodemon." -ForegroundColor Yellow
  Write-Host "2) Run: cd $ROOT\backend ; npm run dev" -ForegroundColor Yellow
  Write-Host "3) Then run this command and confirm solvedIds still includes demo-1:" -ForegroundColor Yellow
  Write-Host '   Invoke-WebRequest http://localhost:8085/progress -UseBasicParsing | Select-Object -ExpandProperty Content' -ForegroundColor Yellow

  Write-Host "`nReturned to project root: $ROOT" -ForegroundColor DarkGray
}
finally {
  cd $ROOT
}
