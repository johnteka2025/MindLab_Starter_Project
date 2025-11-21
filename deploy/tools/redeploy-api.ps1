$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
Write-Host "Rebuilding API..." -ForegroundColor Cyan
docker compose -f .\prod\docker-compose.prod.yml --env-file .\prod\.env build api
docker compose -f .\prod\docker-compose.prod.yml --env-file .\prod\.env up -d api

# Wait briefly and verify endpoint
$ok = $false
for ($i=1; $i -le 30 -and -not $ok; $i++) {
  try {
    $r = Invoke-RestMethod "http://localhost/api/health" -TimeoutSec 3
    if ($r -and $r.ok -eq $true) { $ok = $true; break }
  } catch {}
  Start-Sleep -Milliseconds 800
}
if (-not $ok) { Write-Host "API did not come back healthy" -ForegroundColor Yellow; exit 1 }
Write-Host "API redeployed & healthy." -ForegroundColor Green
