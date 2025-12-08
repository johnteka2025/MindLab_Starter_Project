[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$projectRoot   = "C:\Projects\MindLab_Starter_Project"
$dailyRoutine  = Join-Path $projectRoot "run_mindlab_daily_routine.ps1"
$dailyUiScript = Join-Path $projectRoot "run_daily_ui_test.ps1"

Write-Host "=== MindLab daily START (backend stack + UI test) ===" -ForegroundColor Cyan

if (-not (Test-Path $dailyRoutine)) {
    Write-Host "[ERROR] Daily routine script not found: $dailyRoutine" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $dailyUiScript)) {
    Write-Host "[ERROR] Daily UI script not found: $dailyUiScript" -ForegroundColor Red
    exit 1
}

Push-Location $projectRoot
try {
    # -----------------------------
    # STEP 1 – Backend stack checks
    # -----------------------------
    Write-Host "[STEP 1] Running MindLab daily routine..." -ForegroundColor Yellow
    & $dailyRoutine
    $routineExit = $LASTEXITCODE

    if ($routineExit -ne 0) {
        Write-Host "[RESULT] Daily routine FAILED with exit code $routineExit. Skipping UI test." -ForegroundColor Red
        exit $routineExit
    }

    Write-Host "[STEP 1] Daily routine completed successfully." -ForegroundColor Green

    # ----------------------------------------------
    # STEP 2 – UI smoke (requires Vite dev at 5177)
    # ----------------------------------------------
    Write-Host "[STEP 2] Running Daily UI Playwright test..." -ForegroundColor Yellow
    Write-Host "         (Make sure 'npm run dev' is running in frontend before this step.)" -ForegroundColor DarkYellow

    & $dailyUiScript
    $uiExit = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($uiExit -eq 0) {
    Write-Host "==============================================================" -ForegroundColor DarkGreen
    Write-Host "[RESULT] Daily routine + Daily UI test are GREEN." -ForegroundColor Green
    Write-Host "You are clear to start new feature or development work." -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor DarkGreen
} else {
    Write-Host "==============================================================" -ForegroundColor DarkRed
    Write-Host "[RESULT] Daily routine passed, but UI test FAILED (exit $uiExit)." -ForegroundColor Red
    Write-Host "Check the Playwright output and fix UI issues before feature work." -ForegroundColor Red
    Write-Host "==============================================================" -ForegroundColor DarkRed
}

exit $uiExit
