param(
    [string]$BaseUrl = "http://127.0.0.1:8085",
    [int]$Port = 8085
)

Write-Host "=== MindLab FULL SMOKE TEST ===" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host ""

# ================================
# 1) Ensure port is free
# ================================
Write-Host "[1/5] Checking if port $Port is free..."
$matches = netstat -ano | Select-String ":$Port"

if ($matches) {
    Write-Warning "Port $Port is already in use:"
    $matches | ForEach-Object { Write-Host $_.Line }

    # Extract LAST column as PID
    $line = $matches.Line
    $parts = $line -split "\s+"
    $oldPid = $parts[-1]

    Write-Warning "Attempting to stop old backend (PID $oldPid)..."

    try {
        Stop-Process -Id [int]$oldPid -Force -ErrorAction Stop
        Write-Host "Stopped old backend PID $oldPid" -ForegroundColor Yellow
    }
    catch {
        Write-Warning "Could not stop PID $oldPid. Error: $($_.Exception.Message)"
        Write-Warning "This is often caused by FIN_WAIT_2/CLOSE_WAIT orphan sockets."
        Write-Warning "Continuing..."
    }
}

# ================================
# 2) Start backend
# ================================
Write-Host "[2/5] Starting backend (npm start)..." -ForegroundColor Green

$backendProcess = Start-Process "powershell.exe" -ArgumentList @(
    "-NoLogo",
    "-NoProfile",
    "-Command",
    "cd C:\Projects\MindLab_Starter_Project\backend; npm start"
) -PassThru

Start-Sleep -Seconds 3

# ================================
# 3) Wait for /health
# ================================
Write-Host "[3/5] Waiting for backend health..." -ForegroundColor Green

$maxTries = 20
$healthy = $false

for ($i = 1; $i -le $maxTries; $i++) {
    try {
        $res = Invoke-WebRequest -Uri "$BaseUrl/health" -UseBasicParsing -TimeoutSec 3
        if ($res.StatusCode -eq 200) {
            Write-Host ("Backend healthy on try {0} (HTTP 200)" -f $i) -ForegroundColor Green
            $healthy = $true
            break
        }
    }
    catch {
        Write-Host ("Try {0}: backend not ready..." -f $i)
    }

    Start-Sleep -Seconds 1
}

if (-not $healthy) {
    Write-Error "Backend never became healthy. Aborting."
    Stop-Process -Id $backendProcess.Id -Force
    exit 1
}

# ================================
# 4) Run Playwright tests
# ================================
Write-Host "[4/5] Running Playwright tests..." -ForegroundColor Green

cd C:\Projects\MindLab_Starter_Project\frontend
npm install | Out-Null

Invoke-Expression "npx playwright test --trace=on"
$pwExit = $LASTEXITCODE

# ================================
# 5) Cleanup & summary
# ================================
Write-Host "[5/5] Stopping backend..." -ForegroundColor Green
if ($backendProcess -and -not $backendProcess.HasExited) {
    Stop-Process -Id $backendProcess.Id -Force
}

Write-Host ""
Write-Host "=== SMOKE TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "Playwright exit code: $pwExit"

if ($pwExit -eq 0) {
    Write-Host "FULL SMOKE TEST PASSED ✅" -ForegroundColor Green
} else {
    Write-Host "FULL SMOKE TEST FAILED ❌" -ForegroundColor Red
}

exit $pwExit
