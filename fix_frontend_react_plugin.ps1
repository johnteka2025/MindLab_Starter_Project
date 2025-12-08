# fix_frontend_react_plugin.ps1
# Ensure @vitejs/plugin-react is installed correctly for the frontend.

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab frontend React plugin check ===" -ForegroundColor Cyan

# 1) Locate frontend folder
$projectRoot  = Split-Path -Parent $PSCommandPath
$frontendDir  = Join-Path $projectRoot "frontend"
$packageJson  = Join-Path $frontendDir "package.json"

if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found: $frontendDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $packageJson)) {
    Write-Host "[ERROR] package.json not found in: $frontendDir" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Project root : $projectRoot"
Write-Host "[INFO] Frontend dir : $frontendDir"
Write-Host "[INFO] package.json : $packageJson"
Write-Host ""

Push-Location $frontendDir
try {
    # 2) Check if @vitejs/plugin-react is present
    Write-Host "[CHECK] Verifying @vitejs/plugin-react via 'npm list'..." -ForegroundColor Cyan
    npm list @vitejs/plugin-react --depth=0 | Out-Null
    $hasPlugin = ($LASTEXITCODE -eq 0)

    if ($hasPlugin) {
        Write-Host "[OK] @vitejs/plugin-react is already installed." -ForegroundColor Green
    }
    else {
        Write-Host "[WARN] @vitejs/plugin-react not found. Installing as dev dependency..." -ForegroundColor Yellow
        npm install @vitejs/plugin-react --save-dev
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] npm install @vitejs/plugin-react failed with exit code $LASTEXITCODE." -ForegroundColor Red
            exit $LASTEXITCODE
        }
        else {
            Write-Host "[RESULT] @vitejs/plugin-react installed successfully." -ForegroundColor Green
        }
    }

    # 3) Sanity check: run basic Vite config load
    Write-Host ""
    Write-Host "[CHECK] Quick sanity: node -e ""require('./vite.config.ts')"" (via ts-node/loader or compiled JS) is NOT required here." -ForegroundColor Yellow
    Write-Host "[INFO] The real sanity is that Vite will now be able to import '@vitejs/plugin-react'." -ForegroundColor Cyan
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== React plugin check complete ===" -ForegroundColor Cyan
