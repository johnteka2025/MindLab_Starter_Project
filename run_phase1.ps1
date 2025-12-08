param(
    [switch]$TraceOn
)

# MindLab - Phase 1: Stability and Trust

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 1 - Stability and Trust ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

# Ensure logs directory exists
$logDir = Join-Path $root 'logs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Invoke-Phase1Step {
    param(
        [string]$Name,
        [string]$ScriptName,
        [ref]$ExitCodeRef
    )

    Write-Host ""
    Write-Host $Name -ForegroundColor Cyan

    $scriptPath = Join-Path $root $ScriptName
    if (-not (Test-Path $scriptPath)) {
        Write-Host "ERROR: Script not found: $scriptPath" -ForegroundColor Red
        $ExitCodeRef.Value = 1
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $baseName  = [System.IO.Path]::GetFileNameWithoutExtension($ScriptName)
    $logPath   = Join-Path $logDir ("phase1_{0}_{1}.log" -f $baseName, $timestamp)

    Write-Host "Running: $scriptPath" -ForegroundColor DarkGray
    Write-Host "Log:     $logPath" -ForegroundColor DarkGray

    try {
        & $scriptPath *>&1 | Tee-Object -FilePath $logPath
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
    }
    catch {
        Write-Host "STEP ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $exitCode = 1
    }

    $ExitCodeRef.Value = $exitCode

    if ($exitCode -eq 0) {
        Write-Host "$Name : PASS (exit code 0)" -ForegroundColor Green
    } else {
        Write-Host "$Name : FAIL (exit code $exitCode)" -ForegroundColor Red
    }
}

[int]$runAllExit         = 0
[int]$prodFullExit       = 0
[int]$prodPlaywrightExit = 0

Invoke-Phase1Step -Name "STEP 1 - run_all.ps1 (local and quick prod sanity)" `
                  -ScriptName "run_all.ps1" `
                  -ExitCodeRef ([ref]$runAllExit)

Invoke-Phase1Step -Name "STEP 2 - run_prod_full_check.ps1 (prod sanity and Playwright)" `
                  -ScriptName "run_prod_full_check.ps1" `
                  -ExitCodeRef ([ref]$prodFullExit)

Invoke-Phase1Step -Name "STEP 3 - run_prod_playwright_only.ps1 (prod Playwright only)" `
                  -ScriptName "run_prod_playwright_only.ps1" `
                  -ExitCodeRef ([ref]$prodPlaywrightExit)

Write-Host ""
Write-Host "=== Phase 1 summary ===" -ForegroundColor Cyan

$step1Status = if ($runAllExit -eq 0) { "PASS" } else { "FAIL" }
$step2Status = if ($prodFullExit -eq 0) { "PASS" } else { "FAIL" }
$step3Status = if ($prodPlaywrightExit -eq 0) { "PASS" } else { "FAIL" }

Write-Host ("STEP 1 - run_all.ps1                  : {0} (exit code {1})" -f $step1Status, $runAllExit)
Write-Host ("STEP 2 - run_prod_full_check.ps1      : {0} (exit code {1})" -f $step2Status, $prodFullExit)
Write-Host ("STEP 3 - run_prod_playwright_only.ps1 : {0} (exit code {1})" -f $step3Status, $prodPlaywrightExit)

$allPassed = ($runAllExit -eq 0 -and $prodFullExit -eq 0 -and $prodPlaywrightExit -eq 0)

Write-Host ""

if ($allPassed) {
    Write-Host "[RESULT] Phase 1 - Stability and Trust: PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[RESULT] Phase 1 - Stability and Trust: FAILED" -ForegroundColor Red
    exit 1
}
