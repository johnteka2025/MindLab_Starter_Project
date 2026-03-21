param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $url = "http://127.0.0.1:8085/health"
    $max = 18

    for ($i = 1; $i -le $max; $i++) {
        try {
            $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
            if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
                Write-Host $r.Content
                Complete-Step -Code 0 -Message "OK: backend health reachable"
                return
            }
        }
        catch {
            Start-Sleep -Seconds 3
        }
    }

    throw "STOP: backend health endpoint unreachable after retries"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
