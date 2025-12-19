param(
    [switch]$TraceOn   # reserved, if we later want to pass --trace=on to sub-scripts
)

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"

$fullCheckScript = Join-Path $frontendDir "run_all.ps1"
$gameSuiteScript = Join-Path $projectRoot "run_game_suite.ps1"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " MindLab DAILY STACK (Full Check + Game)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------
# STEP 1 – Sanity: confirm key scripts exist
# ------------------------------------------------
Write-Host "[STEP 1] Verifying required scripts exist..." -ForegroundColor Yellow

$missing = @()

if (-not (Test-Path $fullCheckScript)) {
    $missing += $fullCheckScript
}
if (-not (Test-Path $gameSuiteScript)) {
    $missing += $gameSuiteScript
}

if ($missing.Count -gt 0) {
    Write-Host "[ERROR] The following required scripts are missing:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    Write-Host "[RESULT] DAILY STACK ABORTED due to missing scripts." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] All required scripts found." -ForegroundColor Green
Write-Host ""

# ------------------------------------------------
# STEP 2 – Run LOCAL FULL CHECK (run_all.ps1)
# ------------------------------------------------
Write-Host "[STEP 2] Running LOCAL FULL CHECK (backend + frontend + tests)..." -ForegroundColor Yellow

Push-Location $frontendDir
try {
    & $fullCheckScript
    $fullCheckExit = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($fullCheckExit -ne 0) {
    Write-Host "[RESULT] LOCAL FULL CHECK FAILED (exit code $fullCheckExit)." -ForegroundColor Red
    Write-Host ""
    Write-Host "============ MINDLAB DAILY STACK SUMMARY ===========" -ForegroundColor Cyan
    Write-Host "Local full check : FAIL"
    Write-Host "Game suite       : NOT RUN"
    Write-Host "====================================================" -ForegroundColor Cyan
    exit $fullCheckExit
}

Write-Host "[RESULT] LOCAL FULL CHECK PASSED." -ForegroundColor Green
Write-Host ""

# ------------------------------------------------
# STEP 3 – Run GAME SUITE (run_game_suite.ps1)
# ------------------------------------------------
Write-Host "[STEP 3] Running GAME SUITE (UI + Game Flow)..." -ForegroundColor Yellow

Push-Location $projectRoot
try {
    & $gameSuiteScript
    $gameSuiteExit = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($gameSuiteExit -ne 0) {
    Write-Host "[RESULT] GAME SUITE FAILED (exit code $gameSuiteExit)." -ForegroundColor Red
}
else {
    Write-Host "[RESULT] GAME SUITE PASSED." -ForegroundColor Green
}

# ------------------------------------------------
# STEP 4 – Final DAILY STACK summary
# ------------------------------------------------
Write-Host ""
Write-Host "============ MINDLAB DAILY STACK SUMMARY ===========" -ForegroundColor Cyan
Write-Host "Local full check : $(if ($fullCheckExit  -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "Game suite       : $(if ($gameSuiteExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "====================================================" -ForegroundColor Cyan

if ($gameSuiteExit -ne 0) {
    exit $gameSuiteExit
}

exit 0
