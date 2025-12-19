param(
    [switch]$TraceOn    # optional: add --trace=on to Playwright run
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " LOCAL FULL CHECK (backend + frontend + tests)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------
# STEP 1 – LOCAL sanity script
# --------------------------
Write-Host "[STEP 1] Running LOCAL sanity script (sanity_local.ps1)..." -ForegroundColor Yellow

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$sanityScript = Join-Path $projectRoot "sanity_local.ps1"

if (-not (Test-Path $sanityScript)) {
    Write-Host "ERROR: sanity_local.ps1 not found at $sanityScript" -ForegroundColor Red
    exit 1
}

# Run sanity_local.ps1 and log to file
& $sanityScript -LogToFile
$sanityExit = $LASTEXITCODE

if ($sanityExit -ne 0) {
    Write-Host "[RESULT] LOCAL sanity script FAILED (exit code $sanityExit)." -ForegroundColor Red
    Write-Host "Check log file: $projectRoot\prod_sanity_local.log (or the log path printed above)." 
    exit $sanityExit
}

Write-Host "[RESULT] LOCAL sanity script PASSED." -ForegroundColor Green
Write-Host ""

# --------------------------
# STEP 2 – LOCAL Playwright e2e tests
# --------------------------
Write-Host "[STEP 2] Running LOCAL Playwright e2e tests..." -ForegroundColor Yellow

$frontendDir = "C:\Projects\MindLab_Starter_Project\frontend"
Set-Location $frontendDir

# IMPORTANT:
#  - Playwright likes forward slashes (regex filter)
#  - Windows file system uses backslashes
#  We build filters with "/" and check existence with "\".
$localSpecsFilters = @(
    "tests/e2e/health-and-puzzles.spec.ts",
    "tests/e2e/mindlab-basic.spec.ts",
    "tests/e2e/puzzles-navigation.spec.ts",
    "tests/e2e/mindlab-daily-ui.spec.ts",
    "tests/e2e/mindlab-daily-ui-optional.spec.ts",
    "tests/e2e/mindlab-game-flow.spec.ts"   # NEW – game flow UI spec
)

# Sanity: ensure all spec files exist on disk
$missing = @()
foreach ($filter in $localSpecsFilters) {
    $fsPath = $filter -replace '/', '\'   # convert to Windows-style for Test-Path
    if (-not (Test-Path $fsPath)) {
        $missing += $fsPath
    }
}

if ($missing.Count -gt 0) {
    Write-Host "ERROR: The following local test files were not found on disk:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

# Build Playwright args:
# npx playwright test <filter1> <filter2> ... --reporter=list [--trace=on]
$pwArgs = @("playwright", "test") + $localSpecsFilters

if ($TraceOn) {
    $pwArgs += "--trace=on"
}

$pwArgs += "--reporter=list"

Write-Host "[SANITY] Using Playwright command:" -ForegroundColor DarkCyan
Write-Host ("npx " + ($pwArgs -join " ")) -ForegroundColor DarkCyan
Write-Host ""

# Run Playwright
npx @pwArgs
$playwrightExit = $LASTEXITCODE

if ($playwrightExit -ne 0) {
    Write-Host "[RESULT] LOCAL Playwright tests FAILED (exit code $playwrightExit)." -ForegroundColor Red
} else {
    Write-Host "[RESULT] LOCAL Playwright tests PASSED." -ForegroundColor Green
}

# --------------------------
# STEP 3 – Summary
# --------------------------
Write-Host ""
Write-Host "=========== LOCAL FULL CHECK SUMMARY ===========" -ForegroundColor Cyan
Write-Host "Sanity script : $(if ($sanityExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "Playwright e2e: $(if ($playwrightExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "================================================" -ForegroundColor Cyan

if ($playwrightExit -ne 0) {
    exit $playwrightExit
}

exit 0
