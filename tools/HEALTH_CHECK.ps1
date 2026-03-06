Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $PORT=8085
  $url="http://127.0.0.1:$PORT/health"
  $deadline=(Get-Date).AddSeconds(90)

  while((Get-Date) -lt $deadline){
    try{
      $r = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 5
      if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){
        Write-Host ("OK: /health reachable -> " + $r.StatusCode) -ForegroundColor Green
        return
      }
    } catch { Start-Sleep -Seconds 2 }
    Start-Sleep -Seconds 1
  }

  Stop-With "STOP: /health not reachable after 90s -> $url"
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
