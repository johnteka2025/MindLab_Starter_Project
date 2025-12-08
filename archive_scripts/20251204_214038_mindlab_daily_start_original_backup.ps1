[CmdletBinding()]
param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

# --------------------------------------------------
# Paths
# --------------------------------------------------
$ProjectRoot   = "C:\Projects\MindLab_Starter_Project"
$RunAllScript  = Join-Path $ProjectRoot "run_all.ps1"
$ProdFullScript = Join-Path $ProjectRoot "run_prod_full_check.ps1"

Write-Host "=== MindLab DAILY START ROUTINE ==="
Write-Host "Project root : $ProjectRoot"
Write-Host ""

# Always start from project root
Set-Location $ProjectRoot

function Run-Step {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Args
    )

    Write-Host ""
    Write-Host "---- $Name ----"

    if (-not (Test-Path $ScriptPath)) {
        throw "ERROR: Script not found: $ScriptPath"
    }

    & $ScriptPath @Args
    return $LASTEXITCODE
}

# --------------------------------------------------
# STEP 1 – LOCAL + quick PROD sanity (run_all.ps1)
# --------------------------------------------------
$localExit = Run-Step `
    -Name "STEP 1: LOCAL + quick PROD sanity (run_all.ps1)" `
    -ScriptPath $RunAllScript `
    -Args @()

# --------------------------------------------------
# STEP 2 – FULL PROD sanity + PROD Playwright
# --------------------------------------------------
$prodArgs = @()
if ($TraceOn) {
    $prodArgs += "-TraceOn"
}

$prodExit = Run-Step `
    -Name "STEP 2: FULL PROD sanity + PROD Playwright (run_prod_full_check.ps1)" `
    -ScriptPath $ProdFullScript `
    -Args $prodArgs

# --------------------------------------------------
# SUMMARY
# --------------------------------------------------
Write-Host ""
Write-Host "=== DAILY START SUMMARY ==="

if ($localExit -eq 0) {
    Write-Host "LOCAL + quick PROD sanity (run_all.ps1): PASS"
} else {
    Write-Host "LOCAL + quick PROD sanity (run_all.ps1): FAIL (exit code $localExit)"
}

if ($prodExit -eq 0) {
    Write-Host "FULL PROD sanity + Playwright          : PASS"
} else {
    Write-Host "FULL PROD sanity + Playwright          : FAIL (exit code $prodExit)"
}

Write-Host ""

if (($localExit -eq 0) -and ($prodExit -eq 0)) {
    Write-Host "All checks passed. You are safe to start working on MindLab today."
    exit 0
} else {
    Write-Host "Some checks failed. Review the errors above before making changes."
    if ($prodExit -ne 0) {
        exit $prodExit
    } else {
        exit $localExit
    }
}
