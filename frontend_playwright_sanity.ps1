param()

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Frontend Playwright setup / sanity (v1) ===" -ForegroundColor Cyan

$projectRoot = 'C:\Projects\MindLab_Starter_Project'
$frontendDir = Join-Path $projectRoot 'frontend'

if (-not (Test-Path -LiteralPath $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found: $frontendDir" -ForegroundColor Red
    exit 1
}

Push-Location $frontendDir
try {
    Write-Host "[INFO] In frontend folder: $frontendDir" -ForegroundColor Cyan

    # 1. Show Node / npm / npx versions
    Write-Host "[INFO] Node version :" -NoNewline
    node -v

    Write-Host "[INFO] npm version  :" -NoNewline
    npm -v

    Write-Host "[INFO] npx version  :" -NoNewline
    npx --version

    # 2. Ensure @playwright/test is installed
    Write-Host "[INFO] Ensuring '@playwright/test' dev dependency is installed..." -ForegroundColor Cyan
    $hadPlaywright = $true
    try {
        npm ls @playwright/test --depth=0 | Out-Null
    }
    catch {
        $hadPlaywright = $false
    }

    if (-not $hadPlaywright) {
        Write-Host "[WARN] @playwright/test not found, installing..." -ForegroundColor Yellow
        npm install -D @playwright/test
    }
    else {
        Write-Host "[INFO] @playwright/test already present." -ForegroundColor Green
    }

    # 3. Make sure the CLI works
    Write-Host "[INFO] Verifying Playwright CLI with 'npx playwright --version'..." -ForegroundColor Cyan
    npx playwright --version

    # 4. Optional: Ensure browsers are installed
    Write-Host "[INFO] Running 'npx playwright install' (safe to run multiple times)..." -ForegroundColor Cyan
    npx playwright install

    Write-Host "[RESULT] Playwright CLI is installed and working correctly." -ForegroundColor Green
}
finally {
    Pop-Location
}
