param(
    [string]$FrontendBase = "http://localhost:5177/app"
)

Write-Host "=== MindLab Phase 13.7 – UI sanity for /app and /app/daily ===" -ForegroundColor Cyan
Write-Host "Project root : $((Get-Location).Path)" -ForegroundColor DarkCyan
Write-Host "Frontend base: $FrontendBase" -ForegroundColor DarkCyan
Write-Host ""

# Helper to check a URL and show status + first lines of HTML
function Test-UiEndpoint {
    param(
        [string]$Path
    )

    $url = "$FrontendBase$Path"
    Write-Host "---- Checking $url ----" -ForegroundColor Yellow
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        Write-Host "Status code: $($resp.StatusCode)" -ForegroundColor Green
        Write-Host "Content length: $($resp.RawContentLength)" -ForegroundColor Green
        Write-Host ""
        Write-Host "First 20 lines of HTML:" -ForegroundColor Cyan
        $resp.Content -split "`n" | Select-Object -First 20
    }
    catch {
        Write-Host "ERROR calling $url" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    Write-Host ""
}

# STEP 1 – Check /app root
Test-UiEndpoint -Path ""

# STEP 2 – Check /app/daily
Test-UiEndpoint -Path "/daily"

Write-Host "=== [RESULT] Phase 13.7 UI sanity script completed ===" -ForegroundColor Cyan
