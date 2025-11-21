$ErrorActionPreference = "Stop"
Write-Host "=== Sanity ==="
function Probe([string]$name, [string]$url) {
  try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
      Write-Host ("{0}: OK ({1})" -f $name, $r.StatusCode)
    } else {
      Write-Host ("{0}: UNREACHABLE ({1})" -f $name, $r.StatusCode)
    }
  } catch { Write-Host ("{0}: UNREACHABLE" -f $name) }
}
Probe "/health" "http://127.0.0.1:8085/health"
Probe "Front"   "http://127.0.0.1:5177/"
Write-Host "`nPorts listening?"
Get-NetTCPConnection -State Listen | ? LocalPort -in 8085,5177 | Select LocalAddress,LocalPort,OwningProcess
