# run_progress_ui_test.ps1
# Progress UI Playwright runner using npm.cmd

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendDir  = Join-Path $projectRoot "frontend"
$specPath     = Join-Path $frontendDir "tests\e2e\progress-ui.spec.ts"
$progressUrl  = "http://localhost:5177/app/progress"

Write-Host "== MindLab Progress UI Playwright test (v1, npm.cmd) =="

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
    Write-Host "[ERROR] Progress UI spec not found at: $specPath" -ForegroundColor Red
    Write-Host "[HINT] Run expand_progress_ui_coverage.ps1 (write_progress_ui_spec.ps1) first." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Frontend folder: $frontendDir"
Write-Host "[INFO] Progress UI spec: $specPath"

# ---------------------------------------------------------
# Step 1 – Check PROGRESS URL is reachable
# ---------------------------------------------------------

try {
    Write-Host "[INFO] Checking PROGRESS URL HTTP status via Invoke-WebRequest..."
    $resp = Invoke-WebRequest -Uri $progressUrl -UseBasicParsing -TimeoutSec 10
    Write-Host "[INFO] PROGRESS URL HTTP status: $($resp.StatusCode)"
}
catch {
    Write-Host "[WARN] Could not reach PROGRESS URL: $progressUrl" -ForegroundColor Yellow
    Write-Host "[WARN] HTTP error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "[WARN] Continuing anyway. Playwright tests may fail if the frontend is not running." -ForegroundColor Yellow
}

# ---------------------------------------------------------
# Step 2 – Run npm Playwright script via npm.cmd
# ---------------------------------------------------------

$npmCmd = "npm.cmd"
$npmCmdPath = Get-Command $npmCmd -ErrorAction SilentlyContinue
if (-not $npmCmdPath) {
    Write-Host "[ERROR] npm.cmd not found in PATH. Check your Node/npm installation." -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Using $($npmCmdPath.Source) to run script mindlab-progress-ui..."

Push-Location $frontendDir
& $npmCmd run mindlab-progress-ui
$exitCode = $LASTEXITCODE
Pop-Location

# ---------------------------------------------------------
# Step 3 – Summarize result
# ---------------------------------------------------------

Write-Host ""
Write-Host "======= PROGRESS UI TEST SUMMARY ======="

if ($exitCode -ne 0) {
    Write-Host "Result: Progress UI Playwright test FAILED with exit code $exitCode." -ForegroundColor Red
    Write-Host "Action: Scroll up and review the npm / Playwright output above for specific test failures." -ForegroundColor Red
    exit $exitCode
}

Write-Host "Result: Progress UI Playwright test PASSED." -ForegroundColor Green
exit 0
