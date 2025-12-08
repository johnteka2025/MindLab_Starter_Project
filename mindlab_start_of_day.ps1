# mindlab_start_of_day.ps1
# Daily START OF SESSION routine for MindLab

[CmdletBinding()]
param(
    # If you ever want to skip the PROD checks:
    [switch]$SkipProd
)

$ErrorActionPreference = "Stop"

# Always work from the folder where this script lives
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " MindLab - START OF DAY ROUTINE" -ForegroundColor Cyan
Write-Host " Project root: $ProjectRoot" -ForegroundColor DarkGray
Write-Host "====================================" -ForegroundColor Cyan

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host ">>> STEP: $Name..." -ForegroundColor Yellow

    try {
        & $Action

        if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
            throw "Command in step '$Name' exited with code $LASTEXITCODE"
        }

        Write-Host ">>> STEP RESULT: PASS ($Name)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host ">>> STEP RESULT: FAIL ($Name)" -ForegroundColor Red
        Write-Host "    $_" -ForegroundColor Red
        return $false
    }
}

# --------------------------------------------------
# STEP 1 — Quick LOCAL + PROD sanity (backend+frontend+tests)
# --------------------------------------------------
$runAll = Join-Path $ProjectRoot "run_all.ps1"
if (Test-Path $runAll) {
    Invoke-Step "Quick LOCAL + PROD sanity (run_all.ps1)" { & $runAll }
}
else {
    Write-Host "SKIP: run_all.ps1 not found at $runAll" -ForegroundColor DarkYellow
}

if (-not $SkipProd) {

    # --------------------------------------------------
    # STEP 2 — Full PROD health (Render + PROD Playwright)
    # --------------------------------------------------
    $runProdFull = Join-Path $ProjectRoot "run_prod_full_check.ps1"
    if (Test-Path $runProdFull) {
        Invoke-Step "Full PROD health check (run_prod_full_check.ps1 -TraceOn)" {
            & $runProdFull -TraceOn
        }
    }
    else {
        Write-Host "SKIP: run_prod_full_check.ps1 not found at $runProdFull" -ForegroundColor DarkYellow
    }

    # --------------------------------------------------
    # STEP 3 — Quick PROD Playwright-only test
    # --------------------------------------------------
    $runProdPlaywright = Join-Path $ProjectRoot "run_prod_playwright_only.ps1"
    if (Test-Path $runProdPlaywright) {
        Invoke-Step "Quick PROD Playwright-only test (run_prod_playwright_only.ps1 -TraceOn)" {
            & $runProdPlaywright -TraceOn
        }
    }
    else {
        Write-Host "SKIP: run_prod_playwright_only.ps1 not found at $runProdPlaywright" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "=== START OF DAY ROUTINE COMPLETE ===" -ForegroundColor Cyan
