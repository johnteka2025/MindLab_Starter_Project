param(
    [switch]$TraceOn
)

# MindLab - Phase 4: CI simulation
# - STEP 0: Run daily start with logging
# - STEP 1: Independent LOCAL + PROD health checks
# - STEP 2: Simulated CI job 1 -> run_all.ps1
# - STEP 3: Simulated CI job 2 -> run_prod_full_check.ps1
# - Summary + CI-style exit code (0 = success, 1 = failure)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 4 - CI simulation ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

# Helpers
function Invoke-CiStep {
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

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $baseName  = [System.IO.Path]::GetFileNameWithoutExtension($ScriptName)
    $logPath   = Join-Path $logDir ("phase4_{0}_{1}.log" -f $baseName, $timestamp)

    Write-Host ("Running: {0}" -f $scriptPath) -ForegroundColor DarkGray
    Write-Host ("Log:     {0}" -f $logPath) -ForegroundColor DarkGray

    try {
        & $scriptPath *>&1 | Tee-Object -FilePath $logPath
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

# -----------------------------------------------------------------
# STEP 0 - Run daily start with logging (Phase 0 inside CI sim)
# -----------------------------------------------------------------

Write-Host ""
Write-Host "STEP 0 - Running mindlab_daily_start.ps1 (Phase 0 pre-check)" -ForegroundColor Cyan

$dsTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$dailyLog    = Join-Path $logDir ("phase4_mindlab_daily_start_{0}.log" -f $dsTimestamp)

[int]$dailyExit = 0

try {
    Write-Host ("Daily start log: {0}" -f $dailyLog) -ForegroundColor DarkGray
    .\mindlab_daily_start.ps1 -TraceOn *>&1 | Tee-Object -FilePath $dailyLog
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $dailyExit = $exitCode
}
catch {
    Write-Host ("Daily start ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    $dailyExit = 1
}

if ($dailyExit -eq 0) {
    Write-Host "Daily start PASSED (exit code 0)" -ForegroundColor Green
} else {
    Write-Host "Daily start FAILED (exit code $dailyExit). See daily log before continuing." -ForegroundColor Red
    Write-Host "[RESULT] Phase 4 - CI simulation: FAILED (daily start failed)" -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------
# STEP 1 - Independent health sanity check (LOCAL + PROD)
# -----------------------------------------------------------------

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
    Write-Host "Local backend is not healthy after daily start. Phase 4 CI sim cannot continue." -ForegroundColor Red
    Write-Host "[RESULT] Phase 4 - CI simulation: FAILED (local /health)" -ForegroundColor Red
    exit 1
}

if (-not $prodHealthy) {
    Write-Host "Prod backend is not healthy. Phase 4 CI sim cannot continue." -ForegroundColor Red
    Write-Host "[RESULT] Phase 4 - CI simulation: FAILED (prod /health)" -ForegroundColor Red
    exit 1
}

Write-Host "Health sanity check PASSED for LOCAL and PROD." -ForegroundColor Green

# -----------------------------------------------------------------
# STEP 2 - Simulated CI job 1: run_all.ps1
# -----------------------------------------------------------------

[int]$runAllExit = 0
Invoke-CiStep -Name "CI job 1 - run_all.ps1 (local + quick prod sanity)" `
              -ScriptName "run_all.ps1" `
              -ExitCodeRef ([ref]$runAllExit)

# -----------------------------------------------------------------
# STEP 3 - Simulated CI job 2: run_prod_full_check.ps1
# -----------------------------------------------------------------

[int]$prodFullExit = 0
Invoke-CiStep -Name "CI job 2 - run_prod_full_check.ps1 (prod sanity + Playwright)" `
              -ScriptName "run_prod_full_check.ps1" `
              -ExitCodeRef ([ref]$prodFullExit)

# -----------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------

Write-Host ""
Write-Host "=== Phase 4 - CI simulation summary ===" -ForegroundColor Cyan

$job1Status = if ($runAllExit -eq 0) { "PASS" } else { "FAIL" }
$job2Status = if ($prodFullExit -eq 0) { "PASS" } else { "FAIL" }

Write-Host ("CI job 1 - run_all.ps1             : {0} (exit code {1})" -f $job1Status, $runAllExit)
Write-Host ("CI job 2 - run_prod_full_check.ps1 : {0} (exit code {1})" -f $job2Status, $prodFullExit)

$allOk = ($runAllExit -eq 0 -and $prodFullExit -eq 0)

Write-Host ""

if ($allOk) {
    Write-Host "[RESULT] Phase 4 - CI simulation: PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[RESULT] Phase 4 - CI simulation: FAILED (one or more CI jobs failed)" -ForegroundColor Red
    exit 1
}
