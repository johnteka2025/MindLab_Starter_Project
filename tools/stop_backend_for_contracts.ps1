[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [int]$Port = 3000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$logDir = Join-Path $env:TEMP "mindlab_contract_logs"

# Support BOTH pid styles (old/new)
$pidFiles = @(
  (Join-Path $logDir "backend.pid"),
  (Join-Path $logDir "backend_contract.pid")
)

foreach ($pf in $pidFiles) {
  if (Test-Path $pf) {
    $pidText = (Get-Content -Encoding ASCII $pf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($pidText) { $pidText = $pidText.Trim() }

    if ($pidText -match '^\d+$') {
      $pidToStop = [int]$pidText
      try { Stop-Process -Id $pidToStop -Force -ErrorAction Stop } catch {}
    }

    Remove-Item -Force $pf -ErrorAction SilentlyContinue
  }
}

# Belt+suspenders: stop any LISTENING process on the port
$conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
foreach ($c in $conns) {
  if ($c.OwningProcess -and $c.OwningProcess -gt 0) {
    try { Stop-Process -Id $c.OwningProcess -Force -ErrorAction Stop } catch {}
  }
}

Start-Sleep -Milliseconds 300

# Sanity: port must be free
$still = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
         Where-Object { $_.State -eq "Listen" } | Select-Object -First 1
if ($still) {
  throw ("STOP: Port {0} still LISTENING (OwningProcess={1})." -f $Port, $still.OwningProcess)
}

Write-Host ("OK: Backend stopped. Port={0} is free." -f $Port) -ForegroundColor Green
