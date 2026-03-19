Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $urls = @(
        "http://127.0.0.1:8085/health",
        "http://localhost:8085/health",
        "http://127.0.0.1:8085/",
        "http://localhost:8085/",
        "http://127.0.0.1:3000/health",
        "http://localhost:3000/health",
        "http://127.0.0.1:5000/health",
        "http://localhost:5000/health",
        "http://127.0.0.1:8000/health",
        "http://localhost:8000/health",
        "http://127.0.0.1:3000/",
        "http://localhost:3000/",
        "http://127.0.0.1:5000/",
        "http://localhost:5000/",
        "http://127.0.0.1:8000/",
        "http://localhost:8000/"
    )

    foreach ($url in $urls) {
        try {
            $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 8
            if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 500) {
                Write-Host "OK: reachable -> $($resp.StatusCode) ($url)" -ForegroundColor Green
                exit 0
            }
        }
        catch {
        }
    }

    throw "STOP: backend endpoint unreachable"
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
