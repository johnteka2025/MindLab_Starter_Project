param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $url = "http://127.0.0.1:8085/health"
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10

    if ($r.StatusCode -lt 200 -or $r.StatusCode -ge 300) {
        throw "STOP: unreachable -> $($r.StatusCode) ($url)"
    }

    Write-Host ("OK: reachable -> " + $r.StatusCode + " (" + $url + ")") -ForegroundColor Green
    Complete-Step -Code 0 -Message "OK: health check passed"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
