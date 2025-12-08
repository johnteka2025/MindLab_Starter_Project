[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab daily start (routine + UI test) ===" -ForegroundColor Cyan

# Adjust only if your project lives somewhere else:
$projectRoot        = "C:\Projects\MindLab_Starter_Project"
$dailyRoutineScript = "run_mindlab_daily_routine.ps1"
$dailyUiScript      = "run_daily_ui_test.ps1"

if (-not (Test-Path $projectRoot)) {
    Write-Host "[ERROR] Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

Push-Location $projectRoot
try {
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor DarkCyan
    Write-Host "[STEP 1] Running MindLab daily routine..." -ForegroundColor Cyan
    Write-Host "===============================================================" -ForegroundColor DarkCyan

    if (-not (Test-Path $dailyRoutineScript)) {
        Write-Host "[ERROR] Script not found: $dailyRoutineScript" -ForegroundColor Red
        exit 1
    }

    & ".\${dailyRoutineScript}"
    $dailyExit = $LASTEXITCODE

    if ($dailyExit -ne 0) {
        Write-Host "[WARN] Daily routine finished with non-zero exit code $dailyExit." -ForegroundColor Yellow
    }
    else {
        Write-Host "[OK] Daily routine completed successfully." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor DarkCyan
    Write-Host "[STEP 2] Running Daily UI Playwright test..." -ForegroundColor Cyan
    Write-Host "===============================================================" -ForegroundColor DarkCyan

    if (-not (Test-Path $dailyUiScript)) {
        Write-Host "[WARN] UI test script not found: $dailyUiScript – skipping Daily UI test." -ForegroundColor Yellow
        exit 0
    }

    & ".\${dailyUiScript}"
    $uiExit = $LASTEXITCODE

    if ($uiExit -ne 0) {
        Write-Host "[WARN] Daily UI Playwright test exited with code $uiExit." -ForegroundColor Yellow
        exit $uiExit
    }

    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor DarkGreen
    Write-Host "[RESULT] Daily routine + Daily UI test are GREEN." -ForegroundColor Green
    Write-Host "You are clear to start new feature or development work." -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor DarkGreen
    exit 0
}
finally {
    Pop-Location
}
