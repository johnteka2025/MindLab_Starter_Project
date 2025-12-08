$ErrorActionPreference = "Stop"

Write-Host "=== MindLab frontend: switch /app to use dist bundle ===" -ForegroundColor Cyan

$projectRoot   = Get-Location
$frontendDir   = Join-Path $projectRoot "frontend"
$distDir       = Join-Path $frontendDir "dist"
$distIndex     = Join-Path $distDir "index.html"
$rootIndex     = Join-Path $frontendDir "index.html"
$rootAssetsDir = Join-Path $frontendDir "assets"
$distAssetsDir = Join-Path $distDir "assets"

Write-Host ""
Write-Host "Project root  : $projectRoot"
Write-Host "Frontend dir  : $frontendDir"
Write-Host "Dist dir      : $distDir"
Write-Host ""

if (-not (Test-Path $distIndex)) {
    Write-Host "[ERROR] frontend\dist\index.html not found." -ForegroundColor Red
    Write-Host "Run .\run_frontend_build_sanity.ps1 first." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $distAssetsDir)) {
    Write-Host "[ERROR] frontend\dist\assets folder not found." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Found dist index and assets." -ForegroundColor Green

if (-not (Test-Path $rootAssetsDir)) {
    Write-Host "Creating frontend\assets folder..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $rootAssetsDir | Out-Null
}

Write-Host ""
Write-Host "Copying dist index.html -> frontend\index.html ..." -ForegroundColor Cyan
Copy-Item -Path $distIndex -Destination $rootIndex -Force

Write-Host "Copying dist\assets -> frontend\assets ..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $distAssetsDir "*") -Destination $rootAssetsDir -Recurse -Force

Write-Host ""
Write-Host "Root index.html now:" -ForegroundColor Cyan
Get-Item $rootIndex | Format-List FullName, LastWriteTime, Length

Write-Host ""
Write-Host "Some files in frontend\assets:" -ForegroundColor Cyan
Get-ChildItem $rootAssetsDir | Select-Object -First 5 FullName, Length | Format-Table

Write-Host ""
Write-Host "First 15 lines of frontend\index.html (should reference /assets/*.js, NOT /src/main.tsx):" -ForegroundColor Cyan
Get-Content $rootIndex -TotalCount 15

Write-Host ""
Write-Host "[RESULT] Frontend root now points to built dist bundle." -ForegroundColor Green
