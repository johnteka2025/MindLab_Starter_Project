param(
    [switch]$TraceOn
)

# ----------------------------------------------
# MindLab - Daily Start Orchestrator (FIXED)
# ----------------------------------------------
# - Calls run_all.ps1 (LOCAL + quick PROD sanity)
# - Calls run_prod_full_check.ps1 (FULL PROD sanity + Playwright)
# - Calls run_prod_playwright_only.ps1 (optional extra PROD Playwright run)
# - Uses REAL exit codes from each script (no log-text parsing)
# - Exits 0 only if ALL steps pass
# ----------------------------------------------

$ErrorActionPreference = 'Stop'

# Ensure we are in the project root (where all the *.ps1 scripts live)
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptRoot

Write-Host "=== MindLab Daily Start ===" -ForegroundColor Cyan
Write-Host "Project root: $scriptRoot"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

# Small helper to run a step and capture exit code
function Invoke-MindlabStep {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [ref]$ExitCodeRef,
        [switch]$Required  # if Required and fails, overall result is FAIL
    )

    Write-Host ""
    Write-Host "---- $Name ----" -ForegroundColor Cyan
    Write-Host "Running: $ScriptPath" -ForegroundColor DarkGray

    if (-not (Test-Path $ScriptPath)) {
        Write-Host "ERROR: Script not found: $ScriptPath" -ForegroundColor Red
        $ExitCodeRef.Value = 1
        return
    }

    try {
        # Run the child script.
        # It will print its own output; we only care about the final exit code.
        & $ScriptPath   # no extra arguments for now
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
    }
    else {
        Write-Host "$Name : FAIL (exit code $exitCode)" -ForegroundColor Red
    }
}

# ----------------------------------------------
# Run steps
# ----------------------------------------------

[int]$runAllExit          = 0
[int]$prodFullCheckExit   = 0
[int]$prodPlaywrightExit  = 0

# STEP 1: LOCAL + quick PROD sanity (run_all.ps1)
Invoke-MindlabStep -Name "STEP 1: LOCAL + quick PROD sanity (run_all.ps1)" `
                   -ScriptPath (Join-Path $scriptRoot 'run_all.ps1') `
                   -ExitCodeRef ([ref]$runAllExit) `
                   -Required

# STEP 2: FULL PROD sanity + Playwright (run_prod_full_check.ps1)
Invoke-MindlabStep -Name "STEP 2: FULL PROD sanity + Playwright (run_prod_full_check.ps1)" `
                   -ScriptPath (Join-Path $scriptRoot 'run_prod_full_check.ps1') `
                   -ExitCodeRef ([ref]$prodFullCheckExit) `
                   -Required

# STEP 3: PROD Playwright only (run_prod_playwright_only.ps1)
Invoke-MindlabStep -Name "STEP 3: PROD Playwright only (run_prod_playwright_only.ps1)" `
                   -ScriptPath (Join-Path $scriptRoot 'run_prod_playwright_only.ps1') `
                   -ExitCodeRef ([ref]$prodPlaywrightExit) `
                   -Required

# ----------------------------------------------
# Daily summary based ONLY on exit codes
# ----------------------------------------------

Write-Host ""
Write-Host "=== DAILY START SUMMARY ===" -ForegroundColor Cyan

if ($runAllExit -eq 0) {
    Write-Host "LOCAL + quick PROD sanity (run_all.ps1) : PASS (exit code 0)"
} else {
    Write-Host "LOCAL + quick PROD sanity (run_all.ps1) : FAIL (exit code $runAllExit)"
}

if ($prodFullCheckExit -eq 0) {
    Write-Host "FULL PROD sanity + Playwright (run_prod_full_check.ps1) : PASS (exit code 0)"
} else {
    Write-Host "FULL PROD sanity + Playwright (run_prod_full_check.ps1) : FAIL (exit code $prodFullCheckExit)"
}

if ($prodPlaywrightExit -eq 0) {
    Write-Host "PROD Playwright only (run_prod_playwright_only.ps1) : PASS (exit code 0)"
} else {
    Write-Host "PROD Playwright only (run_prod_playwright_only.ps1) : FAIL (exit code $prodPlaywrightExit)"
}

# Overall result
$allPassed = ($runAllExit -eq 0 -and
              $prodFullCheckExit -eq 0 -and
              $prodPlaywrightExit -eq 0)

Write-Host ""

if ($allPassed) {
    Write-Host "[RESULT] DAILY START PASSED ✅" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "[RESULT] DAILY START FAILED ❌" -ForegroundColor Red
    exit 1
}
