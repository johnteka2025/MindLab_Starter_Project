param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"  # Treat errors as fatal

# Figure out the project root based on this script's location
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "=== MindLab Daily Routine (LOCAL+PROD) ===" -ForegroundColor Cyan
Write-Host "Project root : $projectRoot" -ForegroundColor DarkCyan
Write-Host "Trace mode   : $TraceOn" -ForegroundColor DarkCyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

function Fail-Step {
    param(
        [string]$StepName,
        [System.Exception]$Error
    )
    Write-Host ""
    Write-Host "[RESULT] Daily routine: FAILED at step: $StepName" -ForegroundColor Red
    if ($Error) {
        Write-Host "Reason    : $($Error.Message)" -ForegroundColor Red
    }
    Write-Host "Check the logs or script output for this step, fix the issue, then rerun run_daily_routine.ps1." -ForegroundColor Red
    exit 1
}

# Resolve script paths from the project root
$dailyStartPath       = Join-Path $projectRoot 'mindlab_daily_start.ps1'
$dailySanityScriptPath = Join-Path $projectRoot 'run_daily_sanity_daily.ps1'

# Sanity: confirm both scripts exist
if (-not (Test-Path $dailyStartPath)) {
    Fail-Step "mindlab_daily_start.ps1 (missing file)" ([System.IO.FileNotFoundException]::new($dailyStartPath))
}
if (-not (Test-Path $dailySanityScriptPath)) {
    Fail-Step "run_daily_sanity_daily.ps1 (missing file)" ([System.IO.FileNotFoundException]::new($dailySanityScriptPath))
}

try {
    # ------------------------------------
    # STEP 1 – Full daily start (LOCAL + PROD + PROD Playwright)
    # ------------------------------------
    Write-Host "STEP 1 – Running mindlab_daily_start.ps1 ..." -ForegroundColor Yellow

    # Pass -TraceOn only if user requested it
    if ($TraceOn) {
        & $dailyStartPath -TraceOn
    } else {
        & $dailyStartPath
    }

    Write-Host ""
    Write-Host "STEP 1: mindlab_daily_start.ps1 completed OK." -ForegroundColor Green
    Write-Host ""

    # Always return to project root before step 2
    Set-Location $projectRoot

    # ------------------------------------
    # STEP 2 – Daily endpoints sanity (/daily/status, /daily, /daily/answer)
    # ------------------------------------
    Write-Host "STEP 2 – Running run_daily_sanity_daily.ps1 ..." -ForegroundColor Yellow

    & $dailySanityScriptPath

    Write-Host ""
    Write-Host "STEP 2: run_daily_sanity_daily.ps1 completed OK." -ForegroundColor Green
    Write-Host ""

    # ------------------------------------
    # FINAL RESULT
    # ------------------------------------
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "[RESULT] MindLab daily routine: PASSED ✅" -ForegroundColor Green
    Write-Host "You are clear to start a new phase or development work." -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Cyan
    exit 0
}
catch {
    Fail-Step "MindLab daily routine" $_
}
