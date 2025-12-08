<# 
  MindLab – Optional Daily UI Playwright test
  v3b – clean, location-safe, with sanity checks
#>

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Daily UI OPTIONAL Playwright test (v3b) ==="

# 1) Detect project root (assume we are in the project root)
$projectRoot = Get-Location
if (-not (Test-Path (Join-Path $projectRoot "frontend\package.json"))) {
    throw "[ERROR] Could not find frontend\package.json under '$projectRoot'. Make sure you ran this from C:\Projects\MindLab_Starter_Project."
}

Write-Host "[INFO] Project root (auto-detected): $projectRoot"

# 2) Key paths
$frontendDir = Join-Path $projectRoot "frontend"
$specRelPath = "tests\e2e\mindlab-daily-ui-optional.spec.ts"
$specFsPath  = Join-Path $frontendDir $specRelPath

Write-Host "[INFO] Frontend dir : $frontendDir"
Write-Host "[INFO] Spec FS path : $specFsPath"

if (-not (Test-Path $specFsPath)) {
    throw "[ERROR] Optional spec file not found at: $specFsPath"
}

# 3) Sanity check – Daily UI URL
$dailyUrl = "http://localhost:5177/app/daily"
Write-Host "[INFO] DAILY_UI_URL set to: $dailyUrl"
Write-Host "[INFO] Checking DAILY_UI_URL HTTP status via Invoke-WebRequest..."

try {
    $resp = Invoke-WebRequest -Uri $dailyUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "[INFO] DAILY_UI_URL HTTP status: $($resp.StatusCode)"
} catch {
    Write-Host "[WARN] Could not reach DAILY_UI_URL: $dailyUrl"
    Write-Host "[WARN] This is OK if the frontend dev server is not running yet."
}

# 4) Locate npm executable safely
Write-Host "[INFO] Locating npm on PATH..."

$npmCmd = $null

# Try npm.cmd first (Windows typical)
$npmCandidate = Get-Command npm.cmd -ErrorAction SilentlyContinue
if ($npmCandidate) {
    $npmCmd = $npmCandidate.Source
} else {
    # Fallback: plain "npm"
    $npmCandidate = Get-Command npm -ErrorAction SilentlyContinue
    if ($npmCandidate) {
        $npmCmd = $npmCandidate.Source
    }
}

if (-not $npmCmd) {
    throw "[ERROR] npm was not found in PATH. Make sure Node.js is installed and available."
}

Write-Host "[INFO] Using npm executable: $npmCmd"

# 5) Run the optional UI Playwright test script via npm
$uiExit = 0

Push-Location $frontendDir
try {
    Write-Host "[INFO] Running npm script 'mindlab:daily-ui-optional'..."
    # IMPORTANT: call npm with the real script name, NOT 'npmCmd'
    & $npmCmd "run" "mindlab:daily-ui-optional"
    $uiExit = $LASTEXITCODE
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "================ OPTIONAL DAILY UI TEST SUMMARY ================"

if ($uiExit -eq 0) {
    Write-Host "[RESULT] Optional Daily UI Playwright test PASSED." -ForegroundColor Green
} else {
    Write-Host "[RESULT] Optional Daily UI Playwright test FAILED with exit code $uiExit." -ForegroundColor Red
}

exit $uiExit
