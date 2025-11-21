[CmdletBinding()]
param(
  [string]$BaseUrl = "http://localhost:8085",
  [string]$WebUrl  = "http://localhost:5177"
)

function Test-PortOpen([string]$Addr,[int]$Port,[int]$TimeoutMs=800){
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    $iar = $client.BeginConnect($Addr,$Port,$null,$null)
    [void]$iar.AsyncWaitHandle.WaitOne($TimeoutMs,$false)
    $ok = $client.Connected
    $client.Close()
    return $ok
  } catch { return $false }
}

Write-Host "[INFO] Sanity: files + Docker + ports"

foreach($f in "run_tests.ps1","run_contract.ps1","run_k6.ps1","orchestrate_all.ps1"){
  if (Test-Path (Join-Path $PSScriptRoot $f)) {
    Write-Host "[OK]   Found .\tests\$f" -ForegroundColor Green
  } else {
    Write-Host "[WARN] Missing .\tests\$f" -ForegroundColor Yellow
  }
}

try { docker version *>$null; Write-Host "[OK]   Docker daemon reachable" -ForegroundColor Green }
catch { Write-Host "[WARN] Docker not available" -ForegroundColor Yellow }

$checks = @(
  @{ addr="localhost"; port=8085; name="API"  },
  @{ addr="localhost"; port=5177; name="Web"  }
)

foreach($c in $checks){
  if (Test-PortOpen $c.addr $c.port 700) {
    Write-Host ("[OK]   Port {0} listening ({1})" -f $c.port,$c.name) -ForegroundColor Green
  } else {
    Write-Host ("[WARN] Port {0} NOT listening ({1})" -f $c.port,$c.name) -ForegroundColor Yellow
  }
}

Write-Host "[OK]   Sanity complete." -ForegroundColor Green
