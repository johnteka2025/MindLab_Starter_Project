Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " MindLab dev env + frontend debug" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendDir  = Join-Path $projectRoot "backend"
$frontendDir = Join-Path $projectRoot "frontend"

Set-Location $projectRoot
Write-Host "Project root : $projectRoot" -ForegroundColor Cyan
Write-Host ""

# STEP 0 - Quick pre-check of ports
Write-Host "STEP 0 - Port check before start..." -ForegroundColor Yellow
Test-NetConnection -ComputerName "localhost" -Port 8085 |
    Select-Object ComputerName,RemotePort,TcpTestSucceeded
Test-NetConnection -ComputerName "localhost" -Port 5177 |
    Select-Object ComputerName,RemotePort,TcpTestSucceeded
Write-Host ""

# STEP 1 - Start backend dev server
Write-Host "STEP 1 - Starting backend dev server (8085) in new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "Set-Location '$backendDir'; npm run dev"
)

# STEP 2 - Start frontend dev server
Write-Host "STEP 2 - Starting frontend dev server (5177) in new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "Set-Location '$frontendDir'; npm start"
)

# STEP 3 - Wait for servers to boot
Write-Host ""
Write-Host "Waiting 20 seconds for servers to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 20
Write-Host ""

# STEP 4 - Port check after start
Write-Host "STEP 3 - Port check after start..." -ForegroundColor Yellow
Test-NetConnection -ComputerName "localhost" -Port 8085 |
    Select-Object ComputerName,RemotePort,TcpTestSucceeded
Test-NetConnection -ComputerName "localhost" -Port 5177 |
    Select-Object ComputerName,RemotePort,TcpTestSucceeded
Write-Host ""

# STEP 5 - Run the frontend HTTP debug script
Write-Host "STEP 4 - Running run_frontend_debug.ps1 ..." -ForegroundColor Cyan
if (Test-Path ".\run_frontend_debug.ps1") {
    .\run_frontend_debug.ps1
} else {
    Write-Host "ERROR: run_frontend_debug.ps1 not found in $projectRoot" -ForegroundColor Red
}

Write-Host ""
Write-Host "[RESULT] Dev env + frontend debug complete." -ForegroundColor Green
Write-Host "You should now have ONE backend window (8085) and ONE frontend window (5177)." -ForegroundColor Green
Write-Host "Next: open http://localhost:5177/app and http://localhost:5177/app/daily in the browser." -ForegroundColor Green
Write-Host ""

Write-Host "Back at project root:" -ForegroundColor Cyan
Get-Location
