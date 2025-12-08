param(
    [switch] $TraceOn
)

# ============================================
# MindLab Daily Routine
#  - STEP 1: Full daily start (LOCAL + PROD)
#  - STEP 2: Daily /daily* API sanity (run_daily_sanity_daily.ps1)
# ============================================

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$originalLocation = Get-Location

try {
    Set-Location $projectRoot

    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "MindLab daily routine" -ForegroundColor Cyan
    Write-Host "Project root : $projectRoot" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""

    # -------------------------------
    # STEP 1 - mindlab_daily_start.ps1
    # -------------------------------
    Write-Host "STEP 1 - Running mindlab_daily_start.ps1 ..." -ForegroundColor Yellow

    if (-not (Test-Path ".\mindlab_daily_start.ps1")) {
        Write-Host "ERROR: mindlab_daily_start.ps1 not found in $projectRoot" -ForegroundColor Red
        Write-Host "[RESULT] MindLab daily routine : FAILED" -ForegroundColor Red
        exit 1
    }

    $startArgs = @()
    if ($TraceOn) { $startArgs += "-TraceOn" }

    & .\mindlab_daily_start.ps1 @startArgs
    $startExit = $LASTEXITCODE

    if ($startExit -ne 0) {
        Write-Host "[RESULT] STEP 1 FAILED (mindlab_daily_start.ps1 exit code $startExit)" -ForegroundColor Red
        Write-Host "[RESULT] MindLab daily routine : FAILED" -ForegroundColor Red
        exit $startExit
    }
    else {
        Write-Host "[RESULT] STEP 1 PASSED (mindlab_daily_start.ps1)" -ForegroundColor Green
    }

    Write-Host ""

    # ---------------------------------------
    # STEP 2 - run_daily_sanity_daily.ps1
    #  -> auto-detect location anywhere under project root
    # ---------------------------------------
    Write-Host "STEP 2 - Running run_daily_sanity_daily.ps1 ..." -ForegroundColor Yellow

    $sanityScriptItem = Get-ChildItem -Path $projectRoot -Recurse -Filter "run_daily_sanity_daily.ps1" -ErrorAction SilentlyContinue |
                        Select-Object -First 1

    if (-not $sanityScriptItem) {
        Write-Host "ERROR: run_daily_sanity_daily.ps1 not found anywhere under $projectRoot" -ForegroundColor Red
        Write-Host "[HINT] Run a recursive search manually:" -ForegroundColor Yellow
        Write-Host "       Get-ChildItem -Path '$projectRoot' -Recurse -Filter 'run_daily_sanity_daily.ps1'" -ForegroundColor Yellow
        Write-Host "[RESULT] MindLab daily routine : FAILED" -ForegroundColor Red
        exit 1
    }

    $sanityScriptPath = $sanityScriptItem.FullName
    Write-Host ("Found run_daily_sanity_daily.ps1 at: {0}" -f $sanityScriptPath) -ForegroundColor Cyan

    & $sanityScriptPath
    $sanityExit = $LASTEXITCODE

    if ($sanityExit -ne 0) {
        Write-Host "[RESULT] STEP 2 FAILED (run_daily_sanity_daily.ps1 exit code $sanityExit)" -ForegroundColor Red
        Write-Host "[RESULT] MindLab daily routine : FAILED" -ForegroundColor Red
        exit $sanityExit
    }
    else {
        Write-Host "[RESULT] STEP 2 PASSED (Daily /daily* endpoints sanity)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "[RESULT] MindLab daily routine : PASSED ✅" -ForegroundColor Green
    Write-Host "You are clear to start a new phase or development work." -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "[RESULT] MindLab daily routine : FAILED ❌" -ForegroundColor Red
    Write-Host ("Error: {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}
finally {
    Set-Location $originalLocation
    Write-Host ""
    Write-Host ("Back at location : {0}" -f (Get-Location)) -ForegroundColor Cyan
}
