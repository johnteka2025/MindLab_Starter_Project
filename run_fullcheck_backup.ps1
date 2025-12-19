param()

# Simple wrapper to run the frontend full-check backup

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"

Set-Location $frontendDir

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Running FULLCHECK backup (scripts + e2e)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if (-not (Test-Path ".\backup_fullcheck.ps1")) {
    Write-Host "[ERROR] backup_fullcheck.ps1 not found in $frontendDir" -ForegroundColor Red
    exit 1
}

.\backup_fullcheck.ps1
