Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $url = "http://127.0.0.1:8085/health"
    $max = 18

    for ($i = 1; $i -le $max; $i++) {
        try {
            $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
            if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
                Write-Host "OK: backend health reachable" -ForegroundColor Green
                exit 0
            }
        }
        catch {
            Start-Sleep -Seconds 3
        }
    }

    throw "STOP: backend health endpoint unreachable after retries"
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
