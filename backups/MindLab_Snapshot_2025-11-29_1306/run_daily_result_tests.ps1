# MindLab Daily result UI Playwright runner
# Runs only the mindlab-daily-result.spec.ts test.

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

$frontendDir = Join-Path (Get-Location) "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend directory not found: $frontendDir" -ForegroundColor Red
    exit 1
}

Write-Host "=== MindLab Daily result UI tests ===" -ForegroundColor Cyan
Write-Host "[INFO] Frontend dir: $frontendDir" -ForegroundColor Cyan

Push-Location $frontendDir
try {
    Write-Host "[STEP] Running mindlab-daily-result.spec.ts ..." -ForegroundColor Cyan
    npx playwright test tests/e2e/mindlab-daily-result.spec.ts
}
finally {
    Pop-Location
}

Write-Host "[RESULT] Daily result UI tests completed." -ForegroundColor Green
