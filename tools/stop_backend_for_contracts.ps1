[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)][int]$Port = 8085
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$logDir  = Join-Path $env:TEMP "mindlab_contract_logs"
$pidFile = Join-Path $logDir "backend_contract.pid"

function Get-PidFromFile {
  if (-not (Test-Path $pidFile)) { return $null }
  $txt = (Get-Content -Raw -ErrorAction SilentlyContinue $pidFile)
  if (-not $txt) { return $null }
  $txt = $txt.Trim()
  if (-not $txt) { return $null }
  $pid = 0
  if ([int]::TryParse($txt, [ref]$pid)) { return $pid }
  return $null
}

function Stop-Pid {
  param([int]$ProcessId)
  if (-not $ProcessId -or $ProcessId -le 0) { return $false }
  $p = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
  if (-not $p) { return $false }
  Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
  Start-Sleep -Milliseconds 250
  return $true
}

function Stop-ByPidFile {
  $killed = $false
  $pid = Get-PidFromFile
  if ($pid) {
    $killed = Stop-Pid -ProcessId $pid
  }
  if (Test-Path $pidFile) { Remove-Item -Force $pidFile -ErrorAction SilentlyContinue }
  return $killed
}

function Stop-ByPortOwner {
  $killedAny = $false
  $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
  if ($conns) {
    $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($p in $pids) {
      if ($p -and $p -gt 0) {
        if (Stop-Pid -ProcessId $p) { $killedAny = $true }
      }
    }
  }
  Start-Sleep -Milliseconds 250
  return $killedAny
}

Write-Host ("=== STOP BACKEND (Port={0}) ===" -f $Port) -ForegroundColor Cyan

$k1 = Stop-ByPidFile
$k2 = Stop-ByPortOwner

# Verify port is free
$still = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($still) {
  Write-Host "=== STILL LISTENING ===" -ForegroundColor Red
  $still | Select-Object -First 10 | Format-Table -AutoSize | Out-Host
  throw ("STOP: Port {0} still in use after stop." -f $Port)
}

Write-Host ("OK: Backend stopped. Port={0} is free. (pidfileKilled={1}; portKilled={2})" -f $Port,$k1,$k2) -ForegroundColor Green
