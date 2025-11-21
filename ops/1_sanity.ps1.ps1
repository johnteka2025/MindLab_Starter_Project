[CmdletBinding()]
param(
  [string]$ApiBase = "http://localhost:8085",
  [string]$WebBase = "http://localhost:5177"
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT
Write-Host "[SANITY] Begin" -ForegroundColor Cyan

$required = @(
  "tests\run_tests.ps1","tests\run_contract.ps1","tests\run_k6.ps1",
  "tests\orchestrate_all.ps1","tests\openapi.json"
)
$missing = $required | Where-Object { -not (Test-Path $_) }
if ($missing) { Write-Host "[ERROR] Missing files:`n - $([string]::Join("`n - ",$missing))" -ForegroundColor Red; exit 2 }
Write-Host "[OK] Required test scripts present." -ForegroundColor Green

& docker info *> $null
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Docker daemon not reachable. Start Docker Desktop." -ForegroundColor Red; exit 3 }
Write-Host "[OK] Docker daemon reachable." -ForegroundColor Green

function Test-PortListening { param([int]$Port) (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? LocalPort -eq $Port) -ne $null }
$apiPort = ([uri]$ApiBase).Port; $webPort = ([uri]$WebBase).Port
if (Test-PortListening $apiPort) { Write-Host "[OK] Port $apiPort is listening (API candidate)." -ForegroundColor Green } else { Write-Host "[WARN] Port $apiPort NOT listening (API)." -ForegroundColor Yellow }
if (Test-PortListening $webPort) { Write-Host "[OK] Port $webPort is listening (Web candidate)." -ForegroundColor Green } else { Write-Host "[WARN] Port $webPort NOT listening (Web)." -ForegroundColor Yellow }

Write-Host "[SANITY] Complete" -ForegroundColor Green
