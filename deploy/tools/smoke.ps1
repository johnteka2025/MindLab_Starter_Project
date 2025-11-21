param([string]$Base="http://localhost")
$ErrorActionPreference = "Stop"
Write-Host "== SMOKE ==" -ForegroundColor Cyan

# 1) Health
$r = Invoke-RestMethod "$Base/api/health" -TimeoutSec 3
if (-not $r -or $r.ok -ne $true) { throw "health not ok" }
Write-Host "/api/health ok"

# 2) Frontend reachable
$s = Invoke-WebRequest "$Base" -UseBasicParsing -TimeoutSec 3
if ($s.StatusCode -ne 200) { throw "frontend != 200" }
Write-Host "/ (frontend) ok"

Write-Host "Smoke: OK" -ForegroundColor Green
