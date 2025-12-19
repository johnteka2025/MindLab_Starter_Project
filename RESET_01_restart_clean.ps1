# RESET_01_restart_clean.ps1
$ErrorActionPreference = "Stop"

$root    = "C:\Projects\MindLab_Starter_Project"
$backend = Join-Path $root "backend"
$front   = Join-Path $root "frontend"

if (-not (Test-Path $backend)) { throw "Missing backend folder: $backend" }
if (-not (Test-Path $front))   { throw "Missing frontend folder: $front" }

Write-Host "Stopping Node processes..." -ForegroundColor Cyan
Get-Process node -ErrorAction SilentlyContinue | ForEach-Object {
  try { Stop-Process -Id $_.Id -Force -ErrorAction Stop } catch {}
}
Start-Sleep -Seconds 2

Write-Host "Starting BACKEND (npm start) in new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd `"$backend`"; npm start"
)

Write-Host "Starting FRONTEND (npm run dev) in new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd `"$front`"; npm run dev"
)

Write-Host "`nWaiting 6 seconds for servers to come up..." -ForegroundColor Cyan
Start-Sleep -Seconds 6

Write-Host "`nQuick checks:" -ForegroundColor Cyan
try { (Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri "http://localhost:8085/_runtime").StatusCode | Out-Host } catch { Write-Host "Backend _runtime FAILED: $($_.Exception.Message)" -ForegroundColor Red }
try { (Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri "http://localhost:8085/health").StatusCode   | Out-Host } catch { Write-Host "Backend /health FAILED: $($_.Exception.Message)" -ForegroundColor Red }
try { (Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri "http://localhost:8085/puzzles").StatusCode  | Out-Host } catch { Write-Host "Backend /puzzles FAILED: $($_.Exception.Message)" -ForegroundColor Red }
try { (Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri "http://localhost:8085/progress").StatusCode | Out-Host } catch { Write-Host "Backend /progress FAILED: $($_.Exception.Message)" -ForegroundColor Red }

Write-Host "`nNow open:" -ForegroundColor Yellow
Write-Host "http://localhost:5177/app/daily" -ForegroundColor Yellow
Write-Host "http://localhost:5177/app/progress" -ForegroundColor Yellow
