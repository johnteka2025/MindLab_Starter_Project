param(
    [switch]$TraceOn
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "MindLab Phase 13.7 - Daily UI environment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Resolve project root based on this script's location
$scriptPath  = $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath

Write-Host "Back at location : $projectRoot" -ForegroundColor DarkCyan
Write-Host ""

$backendPort  = 8085
$frontendPort = 5177

# Helper: stop any process using a port
function Stop-PortProcess {
    param(
        [int]$Port,
        [string]$Label
    )

    Write-Host "=== Checking for old $Label process on port $Port ===" -ForegroundColor Cyan

    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    } catch {
        $connections = $null
    }

    if ($null -ne $connections) {
        $pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique
        foreach ($procId in $pids) {
            Write-Host "Stopping $Label process with PID $procId on port $Port ..." -ForegroundColor Yellow
            try {
                Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
            } catch {
                # Use formatted string to avoid any variable parsing issues
                $msg = "WARNING: Could not stop PID {0} for {1}: {2}" -f $procId, $Label, $_.Exception.Message
                Write-Host $msg -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No existing $Label process on port $Port." -ForegroundColor Green
    }
}

# STEP 1 - Clean up any existing backend / frontend on those ports
Write-Host "STEP 1 - Cleaning up any old backend/frontend dev servers..." -ForegroundColor Cyan
Write-Host ""

Stop-PortProcess -Port $backendPort  -Label "backend"
Write-Host ""
Stop-PortProcess -Port $frontendPort -Label "frontend"

Write-Host ""
Write-Host "=== Cleanup complete ===" -ForegroundColor Green
Write-Host ""

# STEP 2 - Start backend dev server (new window)
Write-Host "STEP 2 - Starting backend dev server (port $backendPort)..." -ForegroundColor Cyan

$backendCmd = "Set-Location '$projectRoot\backend'; npm run dev"
Write-Host "Backend command: $backendCmd" -ForegroundColor DarkCyan

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    $backendCmd
)

# STEP 3 - Start frontend dev server (new window)
Write-Host ""
Write-Host "STEP 3 - Starting frontend dev server (port $frontendPort)..." -ForegroundColor Cyan

$frontendCmd = "Set-Location '$projectRoot\frontend'; npm start"
Write-Host "Frontend command: $frontendCmd" -ForegroundColor DarkCyan

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    $frontendCmd
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "[RESULT] Dev servers started." -ForegroundColor Green
Write-Host "You should now have ONE backend window (8085) and ONE frontend window (5177)." -ForegroundColor Green
Write-Host "Next: open http://localhost:5177/app and http://localhost:5177/app/daily in the browser." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
