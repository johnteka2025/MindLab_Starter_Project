param(
    [string]$BaseUrl = "http://127.0.0.1:8085"
)

Write-Host "=== MindLab production sanity check ===" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host ""

function Test-Endpoint {
    param(
        [string]$Path,
        [string]$Name
    )

    $url = "$BaseUrl$Path"
    Write-Host "Checking $Name ($url)..."

    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($resp.StatusCode -eq 200) {
            Write-Host "  OK  -> HTTP 200" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  FAIL -> HTTP $($resp.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "  FAIL -> $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

$okBackend  = Test-Endpoint -Path "/"    -Name "Backend health"
$okFrontend = Test-Endpoint -Path "/app" -Name "Frontend app"

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Backend /   OK: $okBackend"
Write-Host "  Frontend /app OK: $okFrontend"

if ($okBackend -and $okFrontend) {
    Write-Host "ALL GOOD ✅" -ForegroundColor Green
    exit 0
} else {
    Write-Host "SOMETHING FAILED ❌" -ForegroundColor Red
    exit 1
}
