<#
  MindLab - Daily Solve UI Playwright test (v1)

  This script:
    - Locates the frontend folder and the daily-solve spec
    - Sanity-checks that files exist
    - Sets DAILY_UI_URL / DAILY_SOLVE_URL
    - Runs the Playwright test with --trace=on
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== MindLab Daily Solve UI Playwright test (v1) ===" -ForegroundColor Cyan

# 1) Work out project root from the script location
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptDir

Write-Host "[INFO] Project root : $projectRoot"

# 2) Frontend + tests + spec paths
$frontendDir = Join-Path $projectRoot 'frontend'
$testsDir    = Join-Path $frontendDir 'tests\e2e'
$specPath    = Join-Path $testsDir 'mindlab-daily-solve.spec.ts'

Write-Host "[INFO] Frontend dir : $frontendDir"
Write-Host "[INFO] Tests dir    : $testsDir"

if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found at: $frontendDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $specPath)) {
    Write-Host "[ERROR] Daily solve spec NOT found at: $specPath" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Spec file found: $specPath" -ForegroundColor Green

# 3) Daily solve URL env vars
$defaultSolveUrl = 'http://localhost:5177/app/daily'
$env:DAILY_UI_URL     = $defaultSolveUrl
$env:DAILY_SOLVE_URL  = $defaultSolveUrl

Write-Host "[INFO] DAILY_UI_URL    = $($env:DAILY_UI_URL)"
Write-Host "[INFO] DAILY_SOLVE_URL = $($env:DAILY_SOLVE_URL)"

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
    $specRelPath = 'tests\e2e\mindlab-daily-solve.spec.ts'
    Write-Host "[INFO] Running: npx playwright test $specRelPath --trace=on"
    & $npxPath playwright test $specRelPath --trace=on
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Host "[RESULT] Daily Solve UI Playwright test FAILED with exit code $exitCode." -ForegroundColor Red
    exit $exitCode
}

Write-Host "[RESULT] Daily Solve UI Playwright test PASSED." -ForegroundColor Green
exit 0
