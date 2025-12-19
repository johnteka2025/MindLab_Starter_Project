$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Daily Check (Backend+Frontend+E2E Smoke) ===" -ForegroundColor Cyan

# --- 0) Verify required URLs respond (fast fail) ---
Write-Host "[0/4] Checking backend /health..." -ForegroundColor Yellow
Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing -TimeoutSec 3 | Out-Null
Write-Host "[OK] Backend /health reachable." -ForegroundColor Green

Write-Host "[0/4] Checking frontend pages..." -ForegroundColor Yellow
Invoke-WebRequest "http://localhost:5177/app/daily" -UseBasicParsing -TimeoutSec 3 | Out-Null
Invoke-WebRequest "http://localhost:5177/app/progress" -UseBasicParsing -TimeoutSec 3 | Out-Null
Write-Host "[OK] Frontend pages reachable." -ForegroundColor Green

# --- 1) API behavior proof (no UI) ---
Write-Host "[1/4] Progress API proof (GET -> POST solve -> GET)..." -ForegroundColor Yellow
$before = Invoke-RestMethod "http://localhost:8085/progress" -TimeoutSec 3
Invoke-RestMethod -Method POST -Uri "http://localhost:8085/progress/solve" -ContentType "application/json" -Body '{"puzzleId":1}' -TimeoutSec 3 | Out-Null
$after = Invoke-RestMethod "http://localhost:8085/progress" -TimeoutSec 3

Write-Host ("Before: total={0} solved={1}" -f $before.total, $before.solved) -ForegroundColor Gray
Write-Host ("After : total={0} solved={1}" -f $after.total, $after.solved) -ForegroundColor Gray

if ($after.solved -lt $before.solved) { throw "Solved went backwards (unexpected)." }
if ($after.total -ne $before.total)    { throw "Total changed unexpectedly." }

Write-Host "[OK] Progress API behaves." -ForegroundColor Green

# --- 2) E2E smoke (fast, stable) ---
Write-Host "[2/4] E2E smoke..." -ForegroundColor Yellow
Set-Location (Join-Path $PSScriptRoot "frontend")
npx playwright test `
  tests/e2e/mindlab-daily-ui-optional.spec.ts `
  tests/e2e/mindlab-progress-ui.spec.ts `
  --reporter=line

Write-Host "`n=== DAILY CHECK PASSED ===" -ForegroundColor Green
