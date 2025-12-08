<#
  MindLab - Daily Result UI Playwright test (v1)

  This script:
    - Locates the frontend folder and daily-result spec
    - Sanity-checks paths
    - Sets DAILY_RESULT_URL (and DAILY_UI_URL as a helper)
    - Runs the Playwright test with --trace=on
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== MindLab Daily Result UI Playwright test (v1) ===" -ForegroundColor Cyan

# 1) Project root from script location
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptDir

Write-Host "[INFO] Project root : $projectRoot"

# 2) Frontend + tests + spec paths
$frontendDir = Join-Path $projectRoot 'frontend'
$testsDir    = Join-Path $frontendDir 'tests\e2e'
$specPath    = Join-Path $testsDir 'mindlab-daily-result.spec.ts'

Write-Host "[INFO] Frontend dir : $frontendDir"
Write-Host "[INFO] Tests dir    : $testsDir"

if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found at: $frontendDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $specPath)) {
    Write-Host "[ERROR] Daily result spec NOT found at: $specPath" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Spec file found: $specPath" -ForegroundColor Green

# 3) Daily result URL env vars
# If the spec uses DAILY_RESULT_URL, we point it at the daily area.
# You can adjust this later if the app has a dedicated /app/daily/result route.
$defaultDailyUrl      = 'http://localhost:5177/app/daily'
$env:DAILY_UI_URL     = $defaultDailyUrl
$env:DAILY_RESULT_URL = $defaultDailyUrl

Write-Host "[INFO] DAILY_UI_URL      = $($env:DAILY_UI_URL)"
Write-Host "[INFO] DAILY_RESULT_URL  = $($env:DAILY_RESULT_URL)"

# 4) Run Playwright
Write-Host "[INFO] Using npm executable: " -NoNewline
$npxPath = Join-Path $env:ProgramFiles 'nodejs\npx.cmd'
if (-not (Test-Path $npxPath)) {
    Write-Host "C:\Program Files\nodejs\npx.cmd NOT found, falling back to 'npx' on PATH." -ForegroundColor Yellow
    $npxPath = 'npx'
} else {
    Write-Host $npxPath
}

Push-Location $frontendDir
try {
    $specRelPath = 'tests\e2e\mindlab-daily-result.spec.ts'
    Write-Host "[INFO] Running: npx playwright test $specRelPath --trace=on"
    & $npxPath playwright test $specRelPath --trace=on
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Host "[RESULT] Daily Result UI Playwright test FAILED with exit code $exitCode." -ForegroundColor Red
    exit $exitCode
}

Write-Host "[RESULT] Daily Result UI Playwright test PASSED." -ForegroundColor Green
exit 0
