[CmdletBinding()]
param(
  [string]$ApiBase = "http://host.docker.internal:8085",
  [string]$K6Script = "tests\k6\script.js"
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Write-Host "[TEST:LOAD] k6 -> $ApiBase using $K6Script" -ForegroundColor Cyan
if (-not (Test-Path $K6Script)) { Write-Host "[ERROR] k6 script not found: $K6Script" -ForegroundColor Red; exit 50 }
$art = "tests\.artifacts\k6_$(Get-Date -Format yyyyMMdd_HHmmss)"; New-Item -ItemType Directory -Force -Path $art | Out-Null
$log = Join-Path $art "k6.console.log"
$cmd = @("run","--rm","-e","K6_WEB_DASHBOARD=false","-e","API_BASE=$ApiBase","-v","${pwd}:/src","-w","/src","grafana/k6:latest","run",$K6Script)
Write-Host "[K6] docker $([string]::Join(' ',$cmd))" -ForegroundColor Yellow
docker @cmd *>&1 | Tee-Object -FilePath $log | Out-Host
if ($LASTEXITCODE -ne 0) { Write-Host "[TEST:LOAD] FAIL — see $log" -ForegroundColor Red; exit 51 }
Write-Host "[TEST:LOAD] PASS" -ForegroundColor Green
