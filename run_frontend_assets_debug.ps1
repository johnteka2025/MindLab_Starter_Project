param(
    [string]$BaseUrl = "http://localhost:5177"
)

Write-Host "=== MindLab frontend ASSETS debug ===" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host ""

# STEP 0 – Check that port 5177 is actually listening
Write-Host "---- STEP 0: Check TCP port 5177 ----" -ForegroundColor Cyan
try {
    $conn = Test-NetConnection -ComputerName "localhost" -Port 5177 -WarningAction SilentlyContinue
    if (-not $conn.TcpTestSucceeded) {
        Write-Host "ERROR: Port 5177 is NOT listening. Frontend dev server is not running." -ForegroundColor Red
        Write-Host "Hint: start UI env from project root with:" -ForegroundColor Yellow
        Write-Host "  .\run_phase13_7_daily_ui.ps1" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "OK: Port 5177 is listening." -ForegroundColor Green
    }
}
catch {
    Write-Host "ERROR checking port 5177: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

function Test-FrontendPath {
    param(
        [string]$Path
    )

    $url = "$BaseUrl$Path"
    Write-Host "---- Checking $url ----" -ForegroundColor Cyan
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        Write-Host "Status code : $($resp.StatusCode)" -ForegroundColor Green
        Write-Host "Content type: $($resp.Headers['Content-Type'])"
        $snippet = $resp.Content.Substring(0, [Math]::Min(200, $resp.Content.Length))
        Write-Host "First ~200 chars:"
        Write-Host $snippet
    }
    catch {
        Write-Host "ERROR calling $url : $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# STEP 1 – Check main app and daily URLs
Test-FrontendPath "/app"
Test-FrontendPath "/app/daily"

# STEP 2 – Check possible JS entrypoints
Test-FrontendPath "/src/main.tsx"
Test-FrontendPath "/assets/main.js"
Test-FrontendPath "/dist/index.html"

Write-Host "=== Frontend assets debug finished ===" -ForegroundColor Cyan
