[CmdletBinding()]
param([string]$BaseUrl="http://localhost:8085")

$runId = (Get-Date).ToString("yyyyMMdd_HHmmss")
$artdir = Join-Path $PSScriptRoot ("..\artifacts\core_{0}" -f $runId)
New-Item -ItemType Directory -Force -Path $artdir | Out-Null

Write-Host "[INFO] Run id:  $runId"
Write-Host "[INFO] BaseUrl: $BaseUrl"

# Warm-up
try {
  $r = Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl + "/api/health") -TimeoutSec 6
  if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
    Write-Host "[OK]   Warm-up /api/health -> $($r.StatusCode)" -ForegroundColor Green
  } else {
    Write-Host "[WARN] Warm-up non-2xx: $($r.StatusCode)" -ForegroundColor Yellow
  }
} catch { Write-Host "[WARN] Warm-up failed: $($_.Exception.Message)" -ForegroundColor Yellow }

$paths = "/api/health","/api/ping"
$rows = foreach($p in $paths){
  try {
    $rx = Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl+$p) -TimeoutSec 6
    [pscustomobject]@{ path=$p; status=$rx.StatusCode; ok=$true }
  } catch {
    Write-Host "[WARN] GET $p failed: $($_.Exception.Message)" -ForegroundColor Yellow
    [pscustomobject]@{ path=$p; status=404; ok=$false }
  }
}

$csv = Join-Path $artdir "results.csv"
$rows | Export-Csv -NoTypeInformation -Path $csv
Write-Host "[OK]   Results -> $csv" -ForegroundColor Green

$errors = ($rows | Where-Object { -not $_.ok }).Count
if ($errors -gt 0) { Write-Host "[WARN] Functional errors: $errors failing checks" -ForegroundColor Yellow }

$summary = [pscustomobject]@{
  run_id = $runId; base_url = $BaseUrl
  total_checks = $rows.Count; errors = $errors
}
$summary | ConvertTo-Json -Depth 20 | Out-File -Encoding UTF8 (Join-Path $artdir "summary.json")
