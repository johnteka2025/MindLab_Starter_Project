# verify_mindlab_environment.ps1
# Sanity check for MindLab project folders & core scripts

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
Write-Host "== MindLab Environment Verification =="

if (-not (Test-Path $projectRoot)) {
    Write-Host "ERROR: Project root not found at: $projectRoot" -ForegroundColor Red
    exit 1
}

Write-Host "Project root found at: $projectRoot" -ForegroundColor Green

$pathsToCheck = @(
    "backend",
    "frontend",
    "frontend\tests\e2e",
    "run_ui_suite.ps1",
    "run_quick_daily_stack.ps1",
    "run_full_day_stack.ps1",
    "run_daily_ui_test.ps1",
    "run_daily_ui_optional_test.ps1",
    "run_progress_ui_test.ps1",
    "write_daily_ui_spec.ps1",
    "write_daily_ui_optional_spec.ps1"
)

$missing = @()

foreach ($relative in $pathsToCheck) {
    $full = Join-Path $projectRoot $relative
    if (Test-Path $full) {
        Write-Host "OK: $relative" -ForegroundColor Green
    } else {
        Write-Host "MISSING: $relative" -ForegroundColor Yellow
        $missing += $relative
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`nEnvironment check completed with missing items:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
    Write-Host "Please create/fix the missing files/folders before proceeding." -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "`nEnvironment looks good. You are ready for the next steps." -ForegroundColor Green
    exit 0
}
