# run_frontend_ui_smoke.ps1
# Runs key Playwright UI specs for MindLab frontend

param()

$ErrorActionPreference = "Stop"

Write-Host "== MindLab Frontend UI Smoke Runner ==" -ForegroundColor Cyan
Write-Host "Project root: C:\Projects\MindLab_Starter_Project" -ForegroundColor DarkCyan
Write-Host ""

# 1) Ensure correct folder
Set-Location "C:\Projects\MindLab_Starter_Project"

# 2) Backend sanity check
if (Test-Path ".\check_backend_8085.ps1") {
    Write-Host "[STEP 1] Backend sanity check..." -ForegroundColor Yellow
    .\check_backend_8085.ps1
    Write-Host ""
}

# 3) Run UI tests
$frontendDir = "C:\Projects\MindLab_Starter_Project\frontend"
Set-Location $frontendDir

#
# HEALTH UI TEST
#
Write-Host "[STEP 2] Running Health UI spec..." -ForegroundColor Yellow
npx playwright test "./tests/e2e/mindlab-health-ui.spec.ts" --trace=on
if ($LASTEXITCODE -ne 0) {
    Write-Host "Health UI spec FAILED." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host ""

#
# DAILY UI TEST
#
Write-Host "[STEP 3] Running Daily UI spec (/app/daily) ..." -ForegroundColor Yellow
npx playwright test "./tests/e2e/mindlab-daily-ui.spec.ts" --trace=on
if ($LASTEXITCODE -ne 0) {
    Write-Host "Daily UI spec FAILED." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host ""

#
# PROGRESS UI TEST
#
Write-Host "[STEP 4] Running Progress UI spec ('app/progress') ..." -ForegroundColor Yellow
npx playwright test "./tests/e2e/mindlab-progress-ui.spec.ts" --trace=on
if ($LASTEXITCODE -ne 0) {
    Write-Host "Progress UI spec FAILED." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host ""

Write-Host "== Frontend UI smoke run finished successfully ==" -ForegroundColor Cyan
