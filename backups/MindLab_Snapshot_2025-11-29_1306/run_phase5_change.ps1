param(
    [switch]$TraceOn
)

# MindLab - Phase 5: Safe change loop
# Runs, in order:
#   - mindlab_daily_start.ps1   (with logging)
#   - Independent health sanity check (LOCAL + PROD)
#   - run_phase2.ps1            (core LOCAL specs)
#   - run_phase3.ps1            (API robustness)
#   - run_phase4_ci.ps1         (CI simulation)
# Produces one overall PASS / FAIL result (exit code 0/1).

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 5 - Safe change loop ===" -ForegroundColor Cyan
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
    $logPath  = Join-Path $logDir ("phase5_{0}_{1}.log" -f $baseName, $ts)

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
# STEP 0 - Run daily start with logging
# ------------------------------------------------------------

Write-Host ""
Write-Host "STEP 0 - Daily start (mindlab_daily_start.ps1)" -ForegroundColor Cyan

$dsTs   = Get-Date -Format "yyyyMMdd_HHmmss"
$dsLog  = Join-Path $logDir ("phase5_mindlab_daily_start_{0}.log" -f $dsTs)
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
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (daily start)" -ForegroundColor Red
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
    Write-Host "Local backend is not healthy after daily start. Fix before proceeding with changes." -ForegroundColor Red
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (local /health)" -ForegroundColor Red
    exit 1
}

if (-not $prodHealthy) {
    Write-Host "Prod backend is not healthy. Fix prod /health before proceeding with changes." -ForegroundColor Red
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (prod /health)" -ForegroundColor Red
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
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (Phase 2)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# STEP 3 - Phase 3 (API robustness)
# ------------------------------------------------------------

[int]$phase3Exit = 0
Run-StepScript -Name "Phase 3 - API robustness (run_phase3.ps1)" `
               -ScriptName "run_phase3.ps1" `
               -ExitCodeRef ([ref]$phase3Exit)

if ($phase3Exit -ne 0) {
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (Phase 3)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# STEP 4 - Phase 4 (CI simulation)
# ------------------------------------------------------------

[int]$phase4Exit = 0
Run-StepScript -Name "Phase 4 - CI simulation (run_phase4_ci.ps1)" `
               -ScriptName "run_phase4_ci.ps1" `
               -ExitCodeRef ([ref]$phase4Exit)

if ($phase4Exit -ne 0) {
    Write-Host "[RESULT] Phase 5 - Safe change loop: FAILED (Phase 4)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# All good
# ------------------------------------------------------------

Write-Host ""
Write-Host "[RESULT] Phase 5 - Safe change loop: PASSED" -ForegroundColor Green
Write-Host "Your change is validated end-to-end (local + prod + CI paths)." -ForegroundColor Green
exit 0
