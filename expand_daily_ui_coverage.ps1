# expand_daily_ui_coverage.ps1
# Regenerate Daily UI spec and run Daily UI Playwright test

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$writerScript = Join-Path $projectRoot "write_daily_ui_spec.ps1"
$testScript   = Join-Path $projectRoot "run_daily_ui_test.ps1"

Write-Host "== Expanding Daily UI Coverage =="

if (-not (Test-Path $writerScript)) {
    Write-Host "ERROR: Writer script not found: $writerScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $testScript)) {
    Write-Host "ERROR: Test runner script not found: $testScript" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Generating Daily UI spec..." -ForegroundColor Cyan
& $writerScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Daily UI spec generation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Daily UI spec generated successfully." -ForegroundColor Green

Write-Host "Step 2: Running Daily UI test..." -ForegroundColor Cyan
& $testScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Daily UI test failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Daily UI test passed successfully." -ForegroundColor Green
exit 0
