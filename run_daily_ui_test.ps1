# run_daily_ui_test.ps1
# Daily UI Playwright runner using npm.cmd to avoid npm.ps1 'Statement' error

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"
$specPath    = Join-Path $frontendDir "tests\e2e\mindlab-daily-ui.spec.ts"
$dailyUrl    = "http://localhost:5177/app/daily"

Write-Host "== MindLab Daily UI Playwright test (clean v11, npm.cmd) =="

# ---------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------

if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found: $frontendDir" -ForegroundColor Red
    exit 1
}

$packageJson = Join-Path $frontendDir "package.json"
if (-not (Test-Path $packageJson)) {
    Write-Host "[ERROR] package.json not found in frontend: $packageJson" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $specPath)) {
    Write-Host "[ERROR] Daily UI spec not found at: $specPath" -ForegroundColor Red
    Write-Host "[HINT] Run expand_daily_ui_coverage.ps1 (write_daily_ui_spec.ps1) first." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Frontend folder: $frontendDir"
Write-Host "[INFO] Daily UI spec  : $specPath"

# ---------------------------------------------------------
# Step 1 – Check DAILY UI URL is reachable
# ---------------------------------------------------------

try {
    Write-Host "[INFO] Checking DAILY UI URL HTTP status via Invoke-WebRequest..."
    $resp = Invoke-WebRequest -Uri $dailyUrl -UseBasicParsing -TimeoutSec 10
    Write-Host "[INFO] DAILY UI URL HTTP status: $($resp.StatusCode)"
}
catch {
    Write-Host "[WARN] Could not reach DAILY UI URL: $dailyUrl" -ForegroundColor Yellow
    Write-Host "[WARN] HTTP error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "[WARN] Continuing anyway. Playwright tests may fail if the frontend is not running." -ForegroundColor Yellow
}

# ---------------------------------------------------------
# Step 2 – Run npm Playwright script via npm.cmd (no npm.ps1)
# ---------------------------------------------------------

$npmCmd = "npm.cmd"

$npmCmdPath = Get-Command $npmCmd -ErrorAction SilentlyContinue
if (-not $npmCmdPath) {
    Write-Host "[ERROR] npm.cmd not found in PATH. Check your Node/npm installation." -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Using $($npmCmdPath.Source) to run script mindlab-daily-ui..."

Push-Location $frontendDir
& $npmCmd run mindlab-daily-ui
$exitCode = $LASTEXITCODE
Pop-Location

# ---------------------------------------------------------
# Step 3 – Summarize result
# ---------------------------------------------------------

Write-Host ""
Write-Host "======= DAILY UI TEST SUMMARY ======="

if ($exitCode -ne 0) {
    Write-Host "Result: Daily UI Playwright test FAILED with exit code $exitCode." -ForegroundColor Red
    Write-Host "Action: Scroll up and review the npm / Playwright output above for specific test failures." -ForegroundColor Red
    exit $exitCode
}

Write-Host "Result: Daily UI Playwright test PASSED." -ForegroundColor Green
exit 0
