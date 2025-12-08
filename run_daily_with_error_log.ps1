# run_daily_with_error_log.ps1
# One-shot daily run + error history log

param()
$ErrorActionPreference = "Stop"

# 1. Resolve paths
$projectRoot  = Split-Path -Parent $PSCommandPath
$reportsDir   = Join-Path $projectRoot "reports"
$logsDir      = Join-Path $reportsDir "logs"

$dailyRoutine = Join-Path $projectRoot "run_mindlab_daily_routine.ps1"
$uiSuite      = Join-Path $projectRoot "run_ui_suite.ps1"

# Ensure log directory exists
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

$timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath     = Join-Path $logsDir "mindlab_daily_stack_$timestamp.log"

Write-Host "=== MindLab Daily Stack with Error Log ==="
Write-Host "[INFO] Project root : $projectRoot"
Write-Host "[INFO] Logs folder  : $logsDir"
Write-Host "[INFO] Log file     : $logPath"
Write-Host ""

# 2. Sanity: scripts exist
foreach ($script in @($dailyRoutine, $uiSuite)) {
    if (-not (Test-Path $script)) {
        Write-Host "[ERROR] Required script not found: $script"
        $global:LASTEXITCODE = 1
        exit $global:LASTEXITCODE
    }
}

# 3. Start transcript
Write-Host "[INFO] Starting transcript..."
Start-Transcript -Path $logPath -Force | Out-Null

$dailyExit = 1
$uiExit    = 1

try {
    Write-Host ""
    Write-Host "-----------------------------------------------"
    Write-Host "[STEP 1] Backend daily routine (routes + health)"
    Write-Host "-----------------------------------------------"

    & $dailyRoutine
    $dailyExit = $LASTEXITCODE

    Write-Host ""
    Write-Host "-----------------------------------------------"
    Write-Host "[STEP 2] UI test suite (Daily + Progress)"
    Write-Host "-----------------------------------------------"

    & $uiSuite
    $uiExit = $LASTEXITCODE
}
finally {
    Write-Host ""
    Write-Host "[INFO] Stopping transcript..."
    Stop-Transcript | Out-Null
}

# 4. Summary
Write-Host ""
Write-Host "================ DAILY STACK SUMMARY ================"
Write-Host "Daily routine exit code : $dailyExit"
Write-Host "UI suite exit code      : $uiExit"
Write-Host "Log file                : $logPath"
Write-Host "====================================================="

$overallExit = 0
if ($dailyExit -ne 0 -or $uiExit -ne 0) {
    $overallExit = 1
    Write-Host "[RESULT] Daily stack had issues. Review log:"
    Write-Host "         $logPath"
} else {
    Write-Host "[RESULT] Daily stack COMPLETED with no errors."
    Write-Host "         Full transcript saved at:"
    Write-Host "         $logPath"
}

$global:LASTEXITCODE = $overallExit
exit $global:LASTEXITCODE
