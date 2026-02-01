[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)][int]$Port = 8085
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$start = Join-Path $repoRoot "tools\start_backend_for_contracts.ps1"
$stop  = Join-Path $repoRoot "tools\stop_backend_for_contracts.ps1"

if (-not (Test-Path $start)) { throw "STOP: Missing start script: $start" }
if (-not (Test-Path $stop))  { throw "STOP: Missing stop script:  $stop" }

Write-Host "=== LIFECYCLE GATE: stop -> start -> verify -> stop ===" -ForegroundColor Cyan

# 1) Stop (idempotent)
& $stop -Port $Port

# 2) Start
& $start -Port $Port

# 3) Verify health again (belt & suspenders)
$ok = $false
for ($i=0; $i -lt 20; $i++) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 -Uri ("http://127.0.0.1:{0}/health" -f $Port)
    if ($r.StatusCode -eq 200) { $ok = $true; break }
  } catch {}
  Start-Sleep -Milliseconds 500
}
if (-not $ok) { throw ("STOP: Health did not become 200 on port {0}" -f $Port) }

Write-Host "OK: Verified health=200" -ForegroundColor Green

# 4) Stop again (must free port)
& $stop -Port $Port

Write-Host "OK: Lifecycle gate passed." -ForegroundColor Green
