param(
    [switch]$TraceOn
)

# MindLab - Phase 8 Dev Cycle
# Runs:
#   STEP 1: Phase 6 quick dev loop (core LOCAL specs)
#   STEP 2: Phase 8 Daily Challenge dev loop (LOCAL + PROD specs)
#
# NOTE: Both run_phase6_dev_quick.ps1 and run_phase8_new_feature.ps1
# already:
#   - call mindlab_daily_start.ps1 with logging
#   - perform independent LOCAL + PROD /health checks

$ErrorActionPreference = "Stop"

$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $root "logs"

Set-Location $root
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

Write-Host "=== MindLab Phase 8 Dev Cycle ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

function Invoke-PhaseScript {
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

    try {
        & $scriptPath -TraceOn
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

# STEP 1: Phase 6 quick dev loop (core LOCAL specs)
[int]$phase6Exit = 0
Invoke-PhaseScript -Name "STEP 1 - Phase 6 quick dev loop (run_phase6_dev_quick.ps1)" `
                   -ScriptName "run_phase6_dev_quick.ps1" `
                   -ExitCodeRef ([ref]$phase6Exit)

if ($phase6Exit -ne 0) {
    Write-Host "[RESULT] Phase 8 Dev Cycle: FAILED (Phase 6 quick dev loop failed)" -ForegroundColor Red
    exit 1
}

# STEP 2: Phase 8 Daily Challenge dev loop
[int]$phase8Exit = 0
Invoke-PhaseScript -Name "STEP 2 - Phase 8 Daily Challenge dev loop (run_phase8_new_feature.ps1)" `
                   -ScriptName "run_phase8_new_feature.ps1" `
                   -ExitCodeRef ([ref]$phase8Exit)

if ($phase8Exit -ne 0) {
    Write-Host "[RESULT] Phase 8 Dev Cycle: FAILED (Daily Challenge dev loop failed)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 8 Dev Cycle: PASSED (core + Daily Challenge specs OK)" -ForegroundColor Green
exit 0
