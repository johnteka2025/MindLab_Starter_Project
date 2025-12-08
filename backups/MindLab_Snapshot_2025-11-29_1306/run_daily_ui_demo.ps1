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

Ensure-AtProjectRoot

Write-Host "=== MindLab Daily UI Demo ===" -ForegroundColor Cyan
Write-Host "[STEP 1] Running quick daily stack (run_quick_daily_stack.ps1)..." -ForegroundColor Cyan

# Run the existing trusted stack script
& .\run_quick_daily_stack.ps1
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Host "[ERROR] run_quick_daily_stack.ps1 failed with exit code $exitCode." -ForegroundColor Red
    Write-Host "[INFO] Not opening the browser because the stack is not healthy." -ForegroundColor Yellow
    exit $exitCode
}

Write-Host "[OK] Daily stack is healthy." -ForegroundColor Green

# STEP 2 – Open the main app (from backend 8085)
$mainUrl = "http://localhost:8085/app"
Write-Host "[STEP 2] Opening MindLab app in browser: $mainUrl" -ForegroundColor Cyan

start $mainUrl

Write-Host "[RESULT] MindLab Daily UI demo started. Use the app navigation to reach the Daily view." -ForegroundColor Green
