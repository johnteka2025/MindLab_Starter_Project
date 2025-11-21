[CmdletBinding()]
param([string]$ApiBase = "http://localhost:8085")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Write-Host "[TEST:CORE] -> $ApiBase" -ForegroundColor Cyan
function Must200($p){ $u="$ApiBase$p"; try{ $r=Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 5; if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){Write-Host "[OK] $u ($($r.StatusCode))" -ForegroundColor Green; return $true} }catch{Write-Host "[FAIL] $u — $($_.Exception.Message)" -ForegroundColor Red}; return $false }
if (-not (Must200 "/api/health")) { Write-Host "[TEST:CORE] FAIL" -ForegroundColor Red; exit 30 }
Write-Host "[TEST:CORE] PASS" -ForegroundColor Green
