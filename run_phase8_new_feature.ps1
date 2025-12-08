param(
    [switch]$TraceOn
)

# MindLab - Phase 8: New feature dev loop (Daily Challenge)
# Steps:
#   0) mindlab_daily_start.ps1 with logging
#   1) Independent health sanity check (LOCAL + PROD)
#   2) Run LOCAL Daily Challenge Playwright spec
#   3) Run PROD Daily Challenge Playwright spec

$ErrorActionPreference = "Stop"

$root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir  = Join-Path $root "logs"
$front   = Join-Path $root "frontend"

Set-Location $root
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

Write-Host "=== MindLab Phase 8 - Daily Challenge dev loop ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

########################################################################
# Helper to run a command and tee output to a log file
########################################################################
function Invoke-LoggedCommand {
    param(
        [string]$Name,
        [scriptblock]$Command,
        [string]$LogFile,
        [ref]$ExitCodeRef
    )

    Write-Host ""
    Write-Host ("---- {0} ----" -f $Name) -ForegroundColor Cyan
    Write-Host ("Log: {0}" -f $LogFile) -ForegroundColor DarkGray

    try {
        & $Command *>&1 | Tee-Object -FilePath $LogFile
        $code = $LASTEXITCODE
        if ($null -eq $code) { $code = 0 }
    }
    catch {
        Write-Host ("ERROR running {0}: {1}" -f $Name, $_.Exception.Message) -ForegroundColor Red
        $code = 1
    }

    $ExitCodeRef.Value = $code
    if ($code -eq 0) {
        Write-Host ("{0} : PASS (exit code 0)" -f $Name) -ForegroundColor Green
    } else {
        Write-Host ("{0} : FAIL (exit code {1})" -f $Name, $code) -ForegroundColor Red
    }
}

########################################################################
# STEP 0 — Daily Start
########################################################################

$dsTs  = Get-Date -Format "yyyyMMdd_HHmmss"
$dsLog = Join-Path $logDir ("phase8_daily_start_{0}.log" -f $dsTs)
[int]$dsExit = 0

Invoke-LoggedCommand -Name "STEP 0 - mindlab_daily_start.ps1" `
                     -LogFile $dsLog `
                     -ExitCodeRef ([ref]$dsExit) `
                     -Command { .\mindlab_daily_start.ps1 -TraceOn }

if ($dsExit -ne 0) {
    Write-Host "[RESULT] Phase 8 - FAILED (daily start)" -ForegroundColor Red
    exit 1
}

########################################################################
# STEP 1 — Independent health sanity check
########################################################################

Write-Host ""
Write-Host "STEP 1 - Independent health sanity check (LOCAL + PROD)" -ForegroundColor Cyan

$localBase = "http://localhost:8085"
$prodBase  = "https://mindlab-swpk.onrender.com"

$localOK = $false
$prodOK  = $false

try {
    $hLocal = Invoke-WebRequest -Uri "$localBase/health" -UseBasicParsing -TimeoutSec 10
    Write-Host ("LOCAL /health -> HTTP {0}" -f $hLocal.StatusCode) -ForegroundColor Green
    if ($hLocal.StatusCode -eq 200) { $localOK = $true }
}
catch {
    Write-Host ("LOCAL /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

try {
    $hProd = Invoke-WebRequest -Uri "$prodBase/health" -UseBasicParsing -TimeoutSec 15
    Write-Host ("PROD /health -> HTTP {0}" -f $hProd.StatusCode) -ForegroundColor Green
    if ($hProd.StatusCode -eq 200) { $prodOK = $true }
}
catch {
    Write-Host ("PROD /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

if (-not $localOK -or -not $prodOK) {
    Write-Host "Health sanity check FAILED. Phase 8 aborted." -ForegroundColor Red
    Write-Host "[RESULT] Phase 8 - FAILED (health check)" -ForegroundColor Red
    exit 1
}

Write-Host "Health sanity PASSED for LOCAL and PROD." -ForegroundColor Green

########################################################################
# STEP 2 — LOCAL Daily Challenge Playwright spec
########################################################################

Set-Location $front
$tsLocal = Get-Date -Format "yyyyMMdd_HHmmss"
$localLog = Join-Path $logDir ("phase8_daily_challenge_local_{0}.log" -f $tsLocal)
[int]$localExit = 0

Invoke-LoggedCommand -Name "STEP 2 - LOCAL Daily Challenge spec" `
                     -LogFile $localLog `
                     -ExitCodeRef ([ref]$localExit) `
                     -Command { npx playwright test tests/e2e/daily-challenge.spec.ts --reporter=list }

########################################################################
# STEP 3 — PROD Daily Challenge Playwright spec
########################################################################

$tsProd = Get-Date -Format "yyyyMMdd_HHmmss"
$prodLog = Join-Path $logDir ("phase8_daily_challenge_prod_{0}.log" -f $tsProd)
[int]$prodExit = 0

Invoke-LoggedCommand -Name "STEP 3 - PROD Daily Challenge spec" `
                     -LogFile $prodLog `
                     -ExitCodeRef ([ref]$prodExit) `
                     -Command { npx playwright test tests/e2e/daily-challenge-prod.spec.ts --reporter=list }

########################################################################
# SUMMARY
########################################################################

Write-Host ""
Write-Host "=== Phase 8 - Daily Challenge dev loop summary ===" -ForegroundColor Cyan
Write-Host ("LOCAL Daily Challenge spec : {0}" -f ($(if ($localExit -eq 0) { "PASS" } else { "FAIL" })))
Write-Host ("PROD  Daily Challenge spec : {0}" -f ($(if ($prodExit -eq 0) { "PASS" } else { "FAIL" })))

if ($localExit -eq 0 -and $prodExit -eq 0) {
    Write-Host "[RESULT] Phase 8 - PASSED (all Daily Challenge specs OK or skipped)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[RESULT] Phase 8 - FAILED (see Phase 8 logs for details)" -ForegroundColor Red
    exit 1
}
