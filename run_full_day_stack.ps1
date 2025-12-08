[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "======================================="
Write-Host " MindLab full day stack (Phase 0 + 1) "
Write-Host "======================================="
Write-Host ""

# ---------- 1. Resolve project root ----------

$scriptPath = $PSCommandPath
if (-not $scriptPath) {
    throw "PSCommandPath is empty. Make sure you are running this script from a .ps1 file."
}

$projectRoot = Split-Path -Parent $scriptPath
if (-not (Test-Path $projectRoot)) {
    throw "Project root not found: $projectRoot"
}
Write-Host "[INFO] Project root : $projectRoot"

# Helper to build script paths
function Get-ScriptPath([string]$fileName) {
    $path = Join-Path $projectRoot $fileName
    return $path
}

$dailyRoutineScript   = Get-ScriptPath "run_mindlab_daily_routine.ps1"
$uiSuiteScript        = Get-ScriptPath "run_ui_suite.ps1"
$errorLogScript       = Get-ScriptPath "run_daily_with_error_log.ps1"
$rtfSummaryScript     = Get-ScriptPath "run_daily_rtf_summary.ps1"

# Sanity checks for required scripts
if (-not (Test-Path $dailyRoutineScript)) {
    throw "[ERROR] Required script missing: $dailyRoutineScript"
}
if (-not (Test-Path $uiSuiteScript)) {
    throw "[ERROR] Required script missing: $uiSuiteScript"
}

Write-Host "[INFO] Daily routine script   : $dailyRoutineScript"
Write-Host "[INFO] UI suite script        : $uiSuiteScript"

if (Test-Path $errorLogScript) {
    Write-Host "[INFO] Error log script       : $errorLogScript"
} else {
    Write-Host "[WARN] Error log script not found (optional): $errorLogScript" -ForegroundColor Yellow
    $errorLogScript = $null
}

if (Test-Path $rtfSummaryScript) {
    Write-Host "[INFO] RTF summary script     : $rtfSummaryScript"
} else {
    Write-Host "[WARN] RTF summary script not found (optional): $rtfSummaryScript" -ForegroundColor Yellow
    $rtfSummaryScript = $null
}

Write-Host ""

# ---------- 2. Run Phase 0 – daily routine ----------

$step1Exit = 0
Write-Host "========== STEP 1: Phase 0 daily routine ==========" -ForegroundColor Cyan
try {
    & $dailyRoutineScript
    $step1Exit = $LASTEXITCODE
    Write-Host "[RESULT] Daily routine exit code: $step1Exit"
}
catch {
    Write-Host "[ERROR] Exception while running daily routine: $_" -ForegroundColor Red
    $step1Exit = 1
}

Write-Host ""

# ---------- 3. Run Phase 1 – UI suite ----------

$step2Exit = 0
Write-Host "========== STEP 2: Phase 1 UI suite ==========" -ForegroundColor Cyan
try {
    & $uiSuiteScript
    $step2Exit = $LASTEXITCODE
    Write-Host "[RESULT] UI suite exit code: $step2Exit"
}
catch {
    Write-Host "[ERROR] Exception while running UI suite: $_" -ForegroundColor Red
    $step2Exit = 1
}

Write-Host ""

# ---------- 4. Run error log capture (optional) ----------

$step3Exit = $null
if ($errorLogScript) {
    Write-Host "========== STEP 3: Daily error log (optional) ==========" -ForegroundColor Cyan
    try {
        & $errorLogScript
        $step3Exit = $LASTEXITCODE
        Write-Host "[RESULT] Daily error log exit code: $step3Exit"
    }
    catch {
        Write-Host "[WARN] Exception while running error log script: $_" -ForegroundColor Yellow
        $step3Exit = 1
    }
} else {
    Write-Host "[INFO] Skipping error log script (not present)." -ForegroundColor Yellow
}

Write-Host ""

# ---------- 5. Run RTF daily summary (optional) ----------

$step4Exit = $null
if ($rtfSummaryScript) {
    Write-Host "========== STEP 4: RTF daily summary (optional) ==========" -ForegroundColor Cyan
    try {
        & $rtfSummaryScript
        $step4Exit = $LASTEXITCODE
        Write-Host "[RESULT] RTF summary exit code: $step4Exit"
    }
    catch {
        Write-Host "[WARN] Exception while running RTF summary script: $_" -ForegroundColor Yellow
        $step4Exit = 1
    }
} else {
    Write-Host "[INFO] Skipping RTF summary script (not present)." -ForegroundColor Yellow
}

Write-Host ""

# ---------- 6. Stack summary and final exit code ----------

Write-Host "================= FULL DAY STACK SUMMARY =================" -ForegroundColor Cyan
Write-Host ("Phase 0  - Daily routine exit code : {0}" -f $step1Exit)
Write-Host ("Phase 1  - UI suite exit code      : {0}" -f $step2Exit)

if ($step3Exit -ne $null) {
    Write-Host ("Step 3  - Error log exit code      : {0}" -f $step3Exit)
} else {
    Write-Host "Step 3  - Error log                 : skipped"
}

if ($step4Exit -ne $null) {
    Write-Host ("Step 4  - RTF summary exit code    : {0}" -f $step4Exit)
} else {
    Write-Host "Step 4  - RTF summary               : skipped"
}

# Overall: stack is healthy only if Phase 0 and Phase 1 are both green
$overallExit = 0
if ($step1Exit -ne 0 -or $step2Exit -ne 0) {
    $overallExit = 1
}

if ($overallExit -eq 0) {
    Write-Host "[OK] Full day stack complete (Phase 0 + 1 are healthy)." -ForegroundColor Green
} else {
    Write-Host "[ERROR] Full day stack complete (STACK HAD ISSUES - see steps above)." -ForegroundColor Red
}

Write-Host "==========================================================" -ForegroundColor Cyan

exit $overallExit
