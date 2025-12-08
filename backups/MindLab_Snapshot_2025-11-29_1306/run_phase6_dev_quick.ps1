param(
    [switch]$TraceOn
)

# MindLab - Phase 6: Quick dev loop
# Steps:
#   0) mindlab_daily_start.ps1 with logging
#   1) Independent health sanity check (LOCAL + PROD)
#   2) run_phase2.ps1 (core LOCAL Playwright specs)
# Designed for small day-to-day code changes. For full validation, use Phase 5.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 6 - Quick dev loop ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Run-StepScript {
    param(
        [string]$Name,
        [string]$ScriptName,
        [ref]$ExitCodeRef
    )

    Write-Host ""
    Write-Host ("---- {0} ----" -f $Name) -ForegroundColor Cyan

    $scriptPath = Join-Path $root $ScriptName
    if (-not (Test-Path $scriptPath)) {
        Write-Host ("ERROR: Script not found: {0}" -f $scriptPath) -ForegroundColor Red
        $ExitCodeRef.Value = 1
        return
    }

    $ts       = Get-Date -Format "yyyyMMdd_HHmmss"
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptName)
    $logPath  = Join-Path $logDir ("phase6_{0}_{1}.log" -f $baseName, $ts)

    Write-Host ("Running: {0}" -f $scriptPath) -ForegroundColor DarkGray
    Write-Host ("Log:     {0}" -f $logPath) -ForegroundColor DarkGray

    try {
        & $scriptPath -TraceOn *>&1 | Tee-Object -FilePath $logPath
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
    }
    catch {
        Write-Host ("STEP ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
        $exitCode = 1
    }

    $ExitCodeRef.Value = $exitCode

    if ($exitCode -eq 0) {
        Write-Host ("{0} : PASS (exit code 0)" -f $Name) -ForegroundColor Green
    } else {
        Write-Host ("{0} : FAIL (exit code {1})" -f $Name, $exitCode) -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# STEP 0 - Daily start with logging
# ------------------------------------------------------------

Write-Host ""
Write-Host "STEP 0 - Daily start (mindlab_daily_start.ps1)" -ForegroundColor Cyan

$dsTs   = Get-Date -Format "yyyyMMdd_HHmmss"
$dsLog  = Join-Path $logDir ("phase6_mindlab_daily_start_{0}.log" -f $dsTs)
[int]$dsExit = 0

try {
    Write-Host ("Daily start log: {0}" -f $dsLog) -ForegroundColor DarkGray
    .\mindlab_daily_start.ps1 -TraceOn *>&1 | Tee-Object -FilePath $dsLog
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $dsExit = $exitCode
}
catch {
    Write-Host ("Daily start ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    $dsExit = 1
}

if ($dsExit -eq 0) {
    Write-Host "Daily start PASSED (exit code 0)" -ForegroundColor Green
} else {
    Write-Host "Daily start FAILED (exit code $dsExit). See the daily log and fix before continuing." -ForegroundColor Red
    Write-Host "[RESULT] Phase 6 - Quick dev loop: FAILED (daily start)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# STEP 1 - Independent health sanity check (LOCAL + PROD)
# ------------------------------------------------------------

Write-Host ""
Write-Host "STEP 1 - Independent health sanity check (LOCAL + PROD)" -ForegroundColor Cyan

$localBase = "http://localhost:8085"
$prodBase  = "https://mindlab-swpk.onrender.com"

$localHealthy = $false
$prodHealthy  = $false

# LOCAL /health
try {
    $hLocal = Invoke-WebRequest -Uri "$localBase/health" -UseBasicParsing -TimeoutSec 10
    Write-Host ("LOCAL /health -> HTTP {0}" -f $hLocal.StatusCode) -ForegroundColor Green
    if ($hLocal.StatusCode -eq 200) { $localHealthy = $true }
}
catch {
    Write-Host ("LOCAL /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

# PROD /health
try {
    $hProd = Invoke-WebRequest -Uri "$prodBase/health" -UseBasicParsing -TimeoutSec 15
    Write-Host ("PROD /health -> HTTP {0}" -f $hProd.StatusCode) -ForegroundColor Green
    if ($hProd.StatusCode -eq 200) { $prodHealthy = $true }
}
catch {
    Write-Host ("PROD /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

if (-not $localHealthy) {
    Write-Host "Local backend is not healthy after daily start. Fix before proceeding with dev loop." -ForegroundColor Red
    Write-Host "[RESULT] Phase 6 - Quick dev loop: FAILED (local /health)" -ForegroundColor Red
    exit 1
}

if (-not $prodHealthy) {
    Write-Host "Prod backend is not healthy. Fix prod /health before proceeding with dev loop." -ForegroundColor Red
    Write-Host "[RESULT] Phase 6 - Quick dev loop: FAILED (prod /health)" -ForegroundColor Red
    exit 1
}

Write-Host "Health sanity check PASSED for LOCAL and PROD." -ForegroundColor Green

# ------------------------------------------------------------
# STEP 2 - Phase 2 (core LOCAL specs)
# ------------------------------------------------------------

[int]$phase2Exit = 0
Run-StepScript -Name "Phase 2 - Core LOCAL specs (run_phase2.ps1)" `
               -ScriptName "run_phase2.ps1" `
               -ExitCodeRef ([ref]$phase2Exit)

if ($phase2Exit -ne 0) {
    Write-Host "[RESULT] Phase 6 - Quick dev loop: FAILED (Phase 2)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# All good
# ------------------------------------------------------------

Write-Host ""
Write-Host "[RESULT] Phase 6 - Quick dev loop: PASSED" -ForegroundColor Green
Write-Host "Local + prod health + core LOCAL specs are green for this change." -ForegroundColor Green
exit 0
