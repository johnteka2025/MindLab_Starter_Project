# MindLab frontend dev server runner (Vite on port 5177 /app/)
# Run this in its own PowerShell window.

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

Write-Host "=== MindLab frontend dev server (Vite) ===" -ForegroundColor Cyan
Write-Host "[INFO] Using frontend dir: $frontendDir" -ForegroundColor Cyan

Push-Location $frontendDir
try {
    Write-Host "[STEP] Running: npm run dev" -ForegroundColor Cyan
    npm run dev
}
finally {
    Pop-Location
}
