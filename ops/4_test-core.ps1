[CmdletBinding()] param([string]$ApiBase="http://localhost:8085")
$ErrorActionPreference="Stop"; Set-StrictMode -Version Latest
Write-Host "[TEST:CORE] -> $ApiBase" -ForegroundColor Cyan
function Must200([string]$u){
  try { $r=Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 5; return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) }
  catch { return $false }
}
if (-not (Must200 ($ApiBase + "/api/health"))) { Write-Host "[TEST:CORE] FAIL" -ForegroundColor Red; exit 30 }
Write-Host "[TEST:CORE] PASS" -ForegroundColor Green
