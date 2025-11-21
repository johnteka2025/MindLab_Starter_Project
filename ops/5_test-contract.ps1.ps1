[CmdletBinding()]
param(
  [string]$SpecPath = "tests\openapi.json",
  [string]$ServerUrl = "http://host.docker.internal:8085"
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Write-Host "[TEST:CONTRACT] Dredd -> $ServerUrl using $SpecPath" -ForegroundColor Cyan
if (-not (Test-Path $SpecPath)) { Write-Host "[ERROR] Spec not found: $SpecPath" -ForegroundColor Red; exit 40 }
$art = "tests\.artifacts\dredd_$(Get-Date -Format yyyyMMdd_HHmmss)"; New-Item -ItemType Directory -Force -Path $art | Out-Null
$log = Join-Path $art "dredd.console.log"
$cmd = @("run","--rm","-v","${pwd}:/src","-w","/src","-e","DREDD_SERVER=$ServerUrl","apiaryio/dredd:latest","dredd",$SpecPath,$ServerUrl,"--inline-errors","--color","always")
Write-Host "[DREDD] docker $([string]::Join(' ',$cmd))" -ForegroundColor Yellow
docker @cmd *>&1 | Tee-Object -FilePath $log | Out-Host
if ($LASTEXITCODE -ne 0) { Write-Host "[TEST:CONTRACT] FAIL — see $log" -ForegroundColor Red; exit 41 }
Write-Host "[TEST:CONTRACT] PASS" -ForegroundColor Green
