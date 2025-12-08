Write-Host "=== MindLab DEV Daily curl sanity ===" -ForegroundColor Cyan

$ports = 5177..5181
$found = $false

foreach ($p in $ports) {
    $url = "http://localhost:{0}/app/" -f $p
    Write-Host "[CHECK] Trying frontend dev port $p  => $url" -ForegroundColor Yellow

    try {
        $resp = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 5
        Write-Host "[OK] Port $p responded with HTTP $($resp.StatusCode)." -ForegroundColor Green
        $found = $true
        break
    }
    catch {
        Write-Host "[WARN] Port $p did not respond: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

if (-not $found) {
    Write-Host "[ERROR] Could not find an active MindLab Vite dev port on: 5177, 5178, 5179, 5180, 5181." -ForegroundColor Red
    Write-Host "        Make sure the frontend dev server is running (run_frontend_dev_daily.ps1)." -ForegroundColor Red
}
