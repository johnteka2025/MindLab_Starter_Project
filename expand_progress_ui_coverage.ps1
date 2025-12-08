# expand_progress_ui_coverage.ps1
# Regenerate Progress UI spec and run Progress UI Playwright test

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot        = "C:\Projects\MindLab_Starter_Project"
$writerScript       = Join-Path $projectRoot "write_progress_ui_spec.ps1"
$progressTestRunner = Join-Path $projectRoot "run_progress_ui_test.ps1"

Write-Host "== Expanding Progress UI Coverage =="

if (-not (Test-Path $writerScript)) {
    Write-Host "ERROR: Writer script not found: $writerScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $progressTestRunner)) {
    Write-Host "ERROR: Progress UI test runner script not found: $progressTestRunner" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Generating Progress UI spec..." -ForegroundColor Cyan
& $writerScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Progress UI spec generation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Step 2: Running Progress UI test..." -ForegroundColor Cyan
& $progressTestRunner
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Progress UI test failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Progress UI test passed successfully." -ForegroundColor Green
exit 0
