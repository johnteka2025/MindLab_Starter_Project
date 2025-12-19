# INV_00_inventory_entrypoints.ps1
$ErrorActionPreference = "Stop"

function Write-Section($t) {
  Write-Host ""
  Write-Host "==================== $t ====================" -ForegroundColor Cyan
}

$root = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $root)) { throw "Missing project root: $root" }

$backend = Join-Path $root "backend"
$frontend = Join-Path $root "frontend"

Write-Section "Project root"
Write-Host $root -ForegroundColor Yellow

Write-Section "Backend package.json start entry"
$backendPkg = Join-Path $backend "package.json"
if (-not (Test-Path $backendPkg)) { throw "Missing: $backendPkg" }
$pkg = Get-Content $backendPkg -Raw | ConvertFrom-Json
$startCmd = $pkg.scripts.start
Write-Host "npm start => $startCmd" -ForegroundColor Green

Write-Section "Backend server candidates (backend\src)"
$src = Join-Path $backend "src"
Get-ChildItem -Path $src -File -Filter "server.*" |
  Sort-Object LastWriteTime -Descending |
  Select-Object Name, FullName, Length, LastWriteTime |
  Format-Table -AutoSize

Write-Section "Frontend key pages (Daily + Progress candidates)"
$daily = Get-ChildItem -Path $frontend -Recurse -File -Filter "Daily.tsx" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending
$progress = Get-ChildItem -Path $frontend -Recurse -File -Include "Progress.tsx","ProgressPage.tsx","ProgressPanel.tsx" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending

Write-Host "Daily candidates:" -ForegroundColor Yellow
$daily | Select-Object Name, FullName, LastWriteTime | Format-Table -AutoSize

Write-Host "Progress candidates:" -ForegroundColor Yellow
$progress | Select-Object Name, FullName, LastWriteTime | Format-Table -AutoSize

Write-Section "Notes"
Write-Host "Use the backend entry file from npm start (usually src/server.cjs). Patch ONLY that file." -ForegroundColor Green
Write-Host "Do NOT edit server.js or server.ts if npm start uses server.cjs." -ForegroundColor Green
