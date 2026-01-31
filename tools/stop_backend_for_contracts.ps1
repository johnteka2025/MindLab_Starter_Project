[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$logDir  = Join-Path $env:TEMP "mindlab_contract_logs"
$pidFile = Join-Path $logDir "backend_contract.pid"

if (-not (Test-Path $pidFile)) {
  Write-Host "OK: No PID file found; nothing to stop." -ForegroundColor Green
  return
}

$pidText = (Get-Content -Encoding ASCII $pidFile | Select-Object -First 1).Trim()
if (-not $pidText) {
  Remove-Item -Force $pidFile -ErrorAction SilentlyContinue
  Write-Host "OK: Empty PID file removed." -ForegroundColor Green
  return
}

$pid = [int]$pidText
try {
  Stop-Process -Id $pid -Force -ErrorAction Stop
  Write-Host ("OK: Stopped backend PID {0}" -f $pid) -ForegroundColor Green
} catch {
  Write-Host ("NOTE: Could not stop PID {0} (may already be stopped)." -f $pid) -ForegroundColor Yellow
}

Remove-Item -Force $pidFile -ErrorAction SilentlyContinue
Write-Host ("OK: Removed PID file {0}" -f $pidFile) -ForegroundColor Green
