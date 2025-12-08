# expand_daily_ui_optional_coverage.ps1
# Regenerate Optional Daily UI spec (using existing writer) and run Optional Daily UI Playwright test

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$writerScript = Join-Path $projectRoot "write_daily_ui_optional_spec.ps1"
$runnerScript = Join-Path $projectRoot "run_daily_ui_optional_test.ps1"

Write-Host "== Expanding Optional Daily UI Coverage =="

if (-not (Test-Path $writerScript)) {
    Write-Host "ERROR: Writer script not found: $writerScript" -ForegroundColor Red
    Write-Host "       If this is intentional, create or fix write_daily_ui_optional_spec.ps1 first." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $runnerScript)) {
    Write-Host "ERROR: Runner script not found: $runnerScript" -ForegroundColor Red
    Write-Host "       Create or fix run_daily_ui_optional_test.ps1 before running this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Updating Optional Daily UI spec (via writer script)..." -ForegroundColor Cyan
& $writerScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Optional Daily UI spec generation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Step 2: Running Optional Daily UI Playwright test..." -ForegroundColor Cyan
& $runnerScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Optional Daily UI test failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Optional Daily UI test passed successfully." -ForegroundColor Green
exit 0
