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

$root       = Get-Location
$backupRoot = Join-Path $root "backups"

if (-not (Test-Path $backupRoot)) {
    Write-Host "[INFO] Creating backup root folder: $backupRoot" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

$timestamp   = Get-Date -Format "yyyy-MM-dd_HHmm"
$backupDir   = Join-Path $backupRoot "MindLab_Snapshot_$timestamp"
$backupZip   = "$backupDir.zip"

Write-Host "[STEP 1] Creating snapshot folder: $backupDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $backupDir | Out-Null

# Paths to include in backup
$itemsToCopy = @(
    ".\backend\src",
    ".\frontend\src",
    ".\*.ps1"
)

foreach ($item in $itemsToCopy) {
    $sourcePath = Join-Path $root $item
    if (Test-Path $sourcePath) {
        Write-Host "[COPY] $sourcePath -> $backupDir" -ForegroundColor Green
        Copy-Item $sourcePath -Destination $backupDir -Recurse -Force
    }
    else {
        Write-Host "[WARN] Source not found, skipping: $sourcePath" -ForegroundColor Yellow
    }
}

Write-Host "[STEP 2] Creating ZIP archive: $backupZip" -ForegroundColor Cyan

if (Test-Path $backupZip) {
    Write-Host "[INFO] Existing zip found, removing: $backupZip" -ForegroundColor Yellow
    Remove-Item $backupZip -Force
}

Compress-Archive -Path (Join-Path $backupDir '*') -DestinationPath $backupZip

Write-Host "[OK] Snapshot complete." -ForegroundColor Green
Write-Host "      Folder: $backupDir" -ForegroundColor Green
Write-Host "      Zip   : $backupZip" -ForegroundColor Green
