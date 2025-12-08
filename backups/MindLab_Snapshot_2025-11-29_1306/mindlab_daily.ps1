# mindlab_daily.ps1
# Master daily script to run START or END of day routines

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start","End")]
    [string]$Mode
)

$ErrorActionPreference = "Stop"

# Always operate from project root (folder containing this script)
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " MindLab DAILY ROUTINE (Mode: $Mode)" -ForegroundColor Cyan
Write-Host " Project root: $ProjectRoot" -ForegroundColor DarkGray
Write-Host "====================================" -ForegroundColor Cyan

# Helper to run a child script and show PASS / FAIL
function Invoke-DailyStep {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string]$Arguments = ""
    )

    Write-Host ""
    Write-Host ">>> STEP: $Name" -ForegroundColor Yellow
    Write-Host "    Script: $ScriptPath $Arguments" -ForegroundColor DarkGray

    if (-not (Test-Path $ScriptPath)) {
        Write-Host ">>> STEP RESULT: FAIL - Script not found" -ForegroundColor Red
        return $false
    }

    try {
        if ($Arguments) {
            & $ScriptPath @($Arguments)
        } else {
            & $ScriptPath
        }

        if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
            throw "Child script exited with code $LASTEXITCODE"
        }

        Write-Host ">>> STEP RESULT: PASS" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host ">>> STEP RESULT: FAIL" -ForegroundColor Red
        Write-Host "    $_" -ForegroundColor Red
        return $false
    }
}

# Paths to the dedicated routines
$StartScript = Join-Path $ProjectRoot "mindlab_start_of_day.ps1"
$EndScript   = Join-Path $ProjectRoot "mindlab_end_of_day.ps1"

switch ($Mode) {
    "Start" {
        Invoke-DailyStep -Name "START OF DAY routine" -ScriptPath $StartScript | Out-Null
    }
    "End" {
        Invoke-DailyStep -Name "END OF DAY routine" -ScriptPath $EndScript | Out-Null
    }
}

Write-Host ""
Write-Host "=== mindlab_daily.ps1 (Mode: $Mode) COMPLETE ===" -ForegroundColor Cyan
