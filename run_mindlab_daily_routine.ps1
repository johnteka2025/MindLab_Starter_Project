# run_mindlab_daily_routine.ps1
# MindLab daily routine (backend + routes) - stable v3b

param()

$ErrorActionPreference = "Stop"

# 1. Work from the project root (this script's folder)
$projectRoot = Split-Path -Parent $PSCommandPath
Set-Location $projectRoot

Write-Host "============================================================"
Write-Host "MindLab daily routine (v3b) starting..."
Write-Host "Project root : $projectRoot"
Write-Host "============================================================"
Write-Host ""

# Track step exit codes
$step1Exit = 0
$step2Exit = 0

# -------------------------------------------------------------
# STEP 1 – Quick daily stack (backend + frontend sanity)
# -------------------------------------------------------------
Write-Host "STEP 1 – Quick daily stack via run_quick_daily_stack.ps1"
Write-Host "------------------------------------------------------------"

try {
    & "$projectRoot\run_quick_daily_stack.ps1"
    $step1Exit = $LASTEXITCODE
}
catch {
    $step1Exit = 1
    Write-Host "[ERROR] STEP 1 failed: $($_.Exception.Message)"
}

Write-Host ""

# -------------------------------------------------------------
# STEP 2 – Optional route sanity check
#          (health, /puzzles, /progress, /app, /app/daily)
# -------------------------------------------------------------
Write-Host "STEP 2 – Optional route sanity check (health, /puzzles, /progress, /app, /app/daily)"
Write-Host "------------------------------------------------------------"

try {
    & "$projectRoot\run_route_sanity.ps1"
    $step2Exit = $LASTEXITCODE
}
catch {
    $step2Exit = 1
    Write-Host "[ERROR] STEP 2 failed: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "================ DAILY ROUTINE SUMMARY =================="
Write-Host "Quick daily stack      exit code: $step1Exit"
Write-Host "Route sanity checks    exit code: $step2Exit"
Write-Host "========================================================="

if ($step1Exit -eq 0 -and $step2Exit -eq 0) {
    $global:LASTEXITCODE = 0
    Write-Host ""
    Write-Host "[RESULT] MindLab daily routine : COMPLETED"
    Write-Host "[RESULT] You are clear to start new feature or development work."
} else {
    $global:LASTEXITCODE = 1
    Write-Host ""
    Write-Host "[WARN] MindLab daily routine : HAD ISSUES (see logs above)."
}

exit $global:LASTEXITCODE
