param(
    [int]$Port = 8085
)

Write-Host "=== MindLab backend (production) ===" -ForegroundColor Cyan

# 1) Check if port is already in use
Write-Host "Checking if port $Port is already in use..."
$inUse = netstat -ano | Select-String ":$Port"

if ($inUse) {
    Write-Warning "Port $Port is already in use. Details:"
    $inUse | ForEach-Object { Write-Host $_.Line }

    Write-Warning "If this is an old Node process, you can kill it with:"
    Write-Host "  Stop-Process -Id <PID> -Force" -ForegroundColor Yellow
    Write-Warning "Then re-run this script."
    exit 1
}

# 2) Move into backend folder
Set-Location "C:\Projects\MindLab_Starter_Project\backend"

Write-Host "Ensuring backend dependencies are installed (npm install)..."
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Error "npm install failed. Aborting."
    exit 1
}

Write-Host "Starting backend with: npm start" -ForegroundColor Green
Write-Host "Press Ctrl+C in this window to stop the server." -ForegroundColor DarkYellow
Write-Host "============================================="

# 3) Start the Node server (blocking)
npm start
