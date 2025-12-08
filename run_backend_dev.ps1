Write-Host "== MindLab backend DEV server (8085) ==" -ForegroundColor Cyan

# Backend configuration
$env:PORT = "8085"
$env:PUBLIC_BASE_URL = "/app/"

# Change into backend folder and start Node server
Set-Location ".\backend"

Write-Host "[INFO] Current location: $((Get-Location).Path)" -ForegroundColor Cyan
Write-Host "[INFO] Starting backend on http://localhost:8085 ..." -ForegroundColor Cyan

node .\src\server.cjs
