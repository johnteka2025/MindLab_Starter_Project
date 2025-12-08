# MindLab Daily Phase runner
# Runs everything needed to verify the full Daily game experience:
#   1) run_quick_daily_stack.ps1      (core backend + daily routine)
#   2) run_daily_ui_tests.ps1         (Daily page UI)
#   3) run_daily_flow_tests.ps1       (Daily solve-flow UI)
#   4) run_route_sanity.ps1           (8085/5177 routes)

$ErrorActionPreference = "Stop"

function Ensure-AtProjectRoot {
    param(
        [string]$ExpectedRoot = "C:\Projects\MindLab_Starter_Project"
    )
    $current = (Get-Location).ProviderPath
    if ($current -ne $ExpectedRoot) {
        Write-Host "[INFO] Changing location to $ExpectedRoot" -ForegroundColor Cyan
        Set-Location $ExpectedRoot
    }
    Write-Host "[INFO] Current location: $(Get-Location)" -ForegroundColor Green
}

Write-Host "=== MindLab Daily Phase ===" -ForegroundColor Cyan
Ensure-AtProjectRoot

# STEP 1: Core daily stack (backend + daily routine)
Write-Host "`n[STEP 1] Quick daily stack (run_quick_daily_stack.ps1)..." -ForegroundColor Cyan
.\run_quick_daily_stack.ps1

# STEP 2: Daily UI smoke test
Write-Host "`n[STEP 2] Daily UI tests (run_daily_ui_tests.ps1)..." -ForegroundColor Cyan
.\run_daily_ui_tests.ps1

# STEP 3: Daily solve-flow UI test
Write-Host "`n[STEP 3] Daily solve-flow tests (run_daily_flow_tests.ps1)..." -ForegroundColor Cyan
.\run_daily_flow_tests.ps1

# STEP 4: Route sanity (backend + optional dev frontend)
Write-Host "`n[STEP 4] Route sanity checks (run_route_sanity.ps1)..." -ForegroundColor Cyan
.\run_route_sanity.ps1

Write-Host "`n[RESULT] Daily Phase completed." -ForegroundColor Green
