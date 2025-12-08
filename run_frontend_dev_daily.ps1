Write-Host "== MindLab frontend DEV server (Vite) ==" -ForegroundColor Cyan

Set-Location ".\frontend"
Write-Host "[INFO] Current location: $((Get-Location).Path)" -ForegroundColor Cyan

Write-Host "[INFO] Running: npm run dev -- --port 5177" -ForegroundColor Yellow
npm run dev -- --port 5177
