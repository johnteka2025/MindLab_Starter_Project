param(
    [switch]$TraceOn   # optional: pass through to Playwright runs if you want traces
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " MindLab GAME SUITE (UI + Game Flow)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------
# STEP 1 – Core Daily UI Suite
# --------------------------
Write-Host "[STEP 1] Running core Daily UI suite (run_ui_suite.ps1)..." -ForegroundColor Yellow

$projectRoot     = "C:\Projects\MindLab_Starter_Project"
$uiSuiteScript   = Join-Path $projectRoot "run_ui_suite.ps1"

if (-not (Test-Path $uiSuiteScript)) {
    Write-Host "ERROR: run_ui_suite.ps1 not found at $uiSuiteScript" -ForegroundColor Red
    exit 1
}

# Call the existing UI suite (this already runs required + optional Daily UI tests)
& $uiSuiteScript
$uiExit = $LASTEXITCODE

if ($uiExit -ne 0) {
    Write-Host "[RESULT] Core Daily UI suite FAILED (exit code $uiExit)." -ForegroundColor Red
    Write-Host "Stopping game suite early because base UI is not stable."
    Write-Host ""
    Write-Host "=========== MINDLAB GAME SUITE SUMMARY ===========" -ForegroundColor Cyan
    Write-Host "Daily UI suite : FAIL"
    Write-Host "Game Flow UI   : NOT RUN"
    Write-Host "==================================================" -ForegroundColor Cyan
    exit $uiExit
}

Write-Host "[RESULT] Core Daily UI suite PASSED." -ForegroundColor Green
Write-Host ""

# --------------------------
# STEP 2 – Game Flow UI spec
# --------------------------
Write-Host "[STEP 2] Running Game Flow UI spec (run_game_flow_ui.ps1)..." -ForegroundColor Yellow

$frontendDir        = Join-Path $projectRoot "frontend"
$gameFlowScriptPath = Join-Path $frontendDir "run_game_flow_ui.ps1"

if (-not (Test-Path $gameFlowScriptPath)) {
    Write-Host "ERROR: run_game_flow_ui.ps1 not found at $gameFlowScriptPath" -ForegroundColor Red
    Write-Host "Did you save it under frontend\run_game_flow_ui.ps1 ?" -ForegroundColor Red
    Write-Host ""
    Write-Host "=========== MINDLAB GAME SUITE SUMMARY ===========" -ForegroundColor Cyan
    Write-Host "Daily UI suite : PASS"
    Write-Host "Game Flow UI   : MISSING SCRIPT"
    Write-Host "==================================================" -ForegroundColor Cyan
    exit 1
}

Push-Location $frontendDir
try {
    # This script already prints its own header and summary
    & $gameFlowScriptPath
    $gameFlowExit = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($gameFlowExit -ne 0) {
    Write-Host "[RESULT] Game Flow UI test FAILED (exit code $gameFlowExit)." -ForegroundColor Red
}
else {
    Write-Host "[RESULT] Game Flow UI test PASSED." -ForegroundColor Green
}

# --------------------------
# STEP 3 – Suite Summary
# --------------------------
Write-Host ""
Write-Host "=========== MINDLAB GAME SUITE SUMMARY ===========" -ForegroundColor Cyan
Write-Host "Daily UI suite : $(if ($uiExit -eq 0)        { 'PASS' } else { 'FAIL' })"
Write-Host "Game Flow UI   : $(if ($gameFlowExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "==================================================" -ForegroundColor Cyan

if ($gameFlowExit -ne 0) {
    exit $gameFlowExit
}

exit 0
