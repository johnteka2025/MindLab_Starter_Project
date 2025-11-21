[CmdletBinding()]
param(
  [string]$BaseUrl="http://localhost:8085",
  [switch]$RunContract,
  [switch]$RunLoad,
  [switch]$SoftExit
)

$runId  = (Get-Date).ToString("yyyyMMdd_HHmmss")
$artdir = Join-Path $PSScriptRoot ("..\artifacts\orchestrator_{0}" -f $runId)
New-Item -ItemType Directory -Force -Path $artdir | Out-Null
Write-Host "[INFO] Orchestrator run: $runId"
Write-Host "[INFO] BaseUrl: $BaseUrl"

$failed = @()

try { & "$PSScriptRoot\run_tests.ps1" -BaseUrl $BaseUrl; Write-Host "[OK]   Core done." -ForegroundColor Green }
catch { $failed += "core"; Write-Host "[WARN] Core failed: $($_.Exception.Message)" -ForegroundColor Yellow }

if ($RunContract) {
  try { & "$PSScriptRoot\run_contract.ps1" -BaseUrl $BaseUrl; Write-Host "[OK]   Contract passed." -ForegroundColor Green }
  catch { $failed += "contract"; Write-Host "[WARN] Contract failed: $($_.Exception.Message)" -ForegroundColor Yellow }
} else { Write-Host "[WARN] Contract skipped." -ForegroundColor Yellow }

if ($RunLoad) {
  try { & "$PSScriptRoot\run_k6.ps1" -BaseUrl $BaseUrl; Write-Host "[OK]   Load done." -ForegroundColor Green }
  catch { $failed += "load"; Write-Host "[WARN] Load failed: $($_.Exception.Message)" -ForegroundColor Yellow }
} else { Write-Host "[WARN] Load skipped." -ForegroundColor Yellow }

$summary = [pscustomobject]@{
  run_id   = $runId
  base_url = $BaseUrl
  failed   = ($failed -join ", ")
  soft     = [bool]$SoftExit.IsPresent
}
$sumPath = Join-Path $artdir "summary.json"
$summary | ConvertTo-Json -Depth 20 | Out-File -Encoding UTF8 $sumPath
Write-Host "[OK]   Run summary -> $sumPath" -ForegroundColor Green

if ($failed.Count -gt 0) {
  $msg = "Failures: " + ($failed -join ", ") + ". See artifacts."
  if ($SoftExit) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
  else { throw $msg }
} else {
  Write-Host "[OK]   ALL steps passed." -ForegroundColor Green
}
