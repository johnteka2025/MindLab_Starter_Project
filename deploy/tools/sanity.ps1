param(
  [string]$Base = "http://localhost",
  [int]$Tries = 20,
  [int]$DelayMs = 800
)
$ErrorActionPreference = "Stop"

Write-Host "== Sanity ==" -ForegroundColor Cyan

# 1) API via Caddy
$ok = $false
for ($i=1; $i -le $Tries -and -not $ok; $i++) {
  try {
    $h = Invoke-RestMethod "$Base/api/health" -TimeoutSec 3
    if ($h -and $h.ok -eq $true) {
      Write-Host "/api/health:" (ConvertTo-Json $h)
      $ok = $true
      break
    }
  } catch { Start-Sleep -Milliseconds $DelayMs }
}
if (-not $ok) { Write-Host "ERROR hitting $Base/api/health" -ForegroundColor Red; exit 1 }

# 2) Frontend
try {
  $r = Invoke-WebRequest "$Base" -UseBasicParsing -TimeoutSec 3
  Write-Host "/ (frontend):" $r.StatusCode
} catch {
  Write-Host "ERROR hitting $Base/" -ForegroundColor Red
  exit 2
}

Write-Host "OK" -ForegroundColor Green
