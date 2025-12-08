param(
    [switch]$TraceOn
)

# MindLab - Quick environment check
# 0) Runs mindlab_daily_start.ps1 with logging
# 1) Independent health sanity check (LOCAL + PROD)

$ErrorActionPreference = "Stop"

$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $root "logs"

Set-Location $root
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

Write-Host "=== MindLab Quick Environment Check ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

######################################################################
# STEP 0 - Daily start with logging
######################################################################

$ts    = Get-Date -Format "yyyyMMdd_HHmmss"
$dsLog = Join-Path $logDir ("quick_env_daily_start_{0}.log" -f $ts)

Write-Host "`nSTEP 0 - mindlab_daily_start.ps1" -ForegroundColor Cyan
Write-Host ("Log: {0}" -f $dsLog) -ForegroundColor DarkGray

[int]$dsExit = 0
try {
    .\mindlab_daily_start.ps1 -TraceOn *>&1 | Tee-Object -FilePath $dsLog
    $code = $LASTEXITCODE
    if ($null -eq $code) { $code = 0 }
    $dsExit = $code
}
catch {
    Write-Host ("Daily start ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    $dsExit = 1
}

if ($dsExit -ne 0) {
    Write-Host "Daily start FAILED (exit code $dsExit). See log above." -ForegroundColor Red
    Write-Host "[RESULT] Quick environment check: FAILED (daily start)" -ForegroundColor Red
    exit 1
}

Write-Host "Daily start PASSED (exit code 0)." -ForegroundColor Green

######################################################################
# STEP 1 - Independent health sanity check
######################################################################

Write-Host "`nSTEP 1 - Independent health sanity check (LOCAL + PROD)" -ForegroundColor Cyan

$localBase = "http://localhost:8085"
$prodBase  = "https://mindlab-swpk.onrender.com"

$localOK = $false
$prodOK  = $false

# LOCAL /health
try {
    $hLocal = Invoke-WebRequest -Uri "$localBase/health" -UseBasicParsing -TimeoutSec 10
    Write-Host ("LOCAL /health -> HTTP {0}" -f $hLocal.StatusCode) -ForegroundColor Green
    if ($hLocal.StatusCode -eq 200) { $localOK = $true }
}
catch {
    Write-Host ("LOCAL /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

# PROD /health
try {
    $hProd = Invoke-WebRequest -Uri "$prodBase/health" -UseBasicParsing -TimeoutSec 15
    Write-Host ("PROD /health -> HTTP {0}" -f $hProd.StatusCode) -ForegroundColor Green
    if ($hProd.StatusCode -eq 200) { $prodOK = $true }
}
catch {
    Write-Host ("PROD /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

if (-not $localOK -or -not $prodOK) {
    Write-Host "Health sanity FAILED for at least one environment." -ForegroundColor Red
    Write-Host "[RESULT] Quick environment check: FAILED (health)" -ForegroundColor Red
    exit 1
}

Write-Host "Health sanity PASSED for LOCAL and PROD." -ForegroundColor Green
Write-Host "[RESULT] Quick environment check: PASSED" -ForegroundColor Green
exit 0
