# STOP_DEV.ps1
# Stops MindLab backend/frontend dev servers by killing processes bound to ports 8085 and 5177.
# Golden Rules: only target known ports, show what will be killed, no guessing.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ok([string]$msg)   { Write-Host "OK: $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }

function Stop-Port([int]$port) {
  $conns = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
  if (-not $conns) {
    Warn "No process is bound to port $port."
    return
  }

  $procIds = $conns | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($procId in $procIds) {
    try {
      $proc = Get-Process -Id $procId -ErrorAction Stop
      Warn "Stopping PID $procId ($($proc.ProcessName)) bound to port $port..."
      Stop-Process -Id $procId -Force
      Ok "Stopped PID $procId."
    }
    catch {
      Warn ("Could not stop PID {0} on port {1}. Error: {2}" -f $procId, $port, $_.Exception.Message)
    }
  }
}

Stop-Port 8085
Stop-Port 5177

Ok "STOP_DEV completed."
exit 0
