[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)][int]$Port = 8085
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$logDir  = Join-Path $env:TEMP "mindlab_contract_logs"
$pidFile = Join-Path $logDir "backend_contract.pid"

function Get-IntFromFile {
  param([string]$FilePath)
  if (-not (Test-Path $FilePath)) { return $null }
  $txt = (Get-Content -Raw -ErrorAction SilentlyContinue $FilePath)
  if (-not $txt) { return $null }
  $txt = $txt.Trim()
  if (-not $txt) { return $null }
  $n = 0
  if ([int]::TryParse($txt, [ref]$n) -and $n -gt 0) { return $n }
  return $null
}

function Stop-Proc {
  param([int]$ProcId)
  if (-not $ProcId -or $ProcId -le 0) { return $false }
  $p = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
  if (-not $p) { return $false }
  try {
    Stop-Process -Id $ProcId -Force -ErrorAction Stop
  } catch {
    return $false
  }
  Start-Sleep -Milliseconds 250
  return $true
}

function Get-PortOwnerPids {
  param([int]$P)
  $pids = @()
  try {
    $conns = Get-NetTCPConnection -LocalPort $P -ErrorAction Stop
    $pids = @($conns | Select-Object -ExpandProperty OwningProcess -Unique)
  } catch {
    # If Get-NetTCPConnection fails, fallback to netstat parsing
    $lines = & netstat -ano 2>$null | Select-String -Pattern (":$P\s") -ErrorAction SilentlyContinue
    foreach ($ln in $lines) {
      $parts = ($ln.Line -split "\s+") | Where-Object { $_ -ne "" }
      if ($parts.Count -ge 5) {
        $maybePid = $parts[-1]
        $n = 0
        if ([int]::TryParse($maybePid, [ref]$n) -and $n -gt 0) { $pids += $n }
      }
    }
    $pids = @($pids | Sort-Object -Unique)
  }
  return $pids
}

Write-Host ("=== STOP BACKEND (Port={0}) ===" -f $Port) -ForegroundColor Cyan

$killedPidFile = $false
$killedPort    = $false

# 1) Kill by pidfile (if present)
$pidFromFile = Get-IntFromFile -FilePath $pidFile
if ($pidFromFile) {
  $killedPidFile = Stop-Proc -ProcId $pidFromFile
}
if (Test-Path $pidFile) {
  Remove-Item -Force $pidFile -ErrorAction SilentlyContinue
}

# 2) Kill by port owner(s)
$ownerPids = Get-PortOwnerPids -P $Port
foreach ($ownerPid in $ownerPids) {
  if (Stop-Proc -ProcId $ownerPid) { $killedPort = $true }
}

# 3) Verify port is free
$still = $null
try {
  $still = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
} catch {
  $still = $null
}

if ($still) {
  Write-Host "=== STILL LISTENING (Get-NetTCPConnection) ===" -ForegroundColor Red
  $still | Select-Object -First 10 | Format-Table -AutoSize | Out-Host
  throw ("STOP: Port {0} still in use after stop." -f $Port)
}

# netstat verification (secondary)
$net = & netstat -ano 2>$null | Select-String -Pattern (":$Port\s") -ErrorAction SilentlyContinue
if ($net) {
  Write-Host "=== STILL LISTENING (netstat) ===" -ForegroundColor Red
  $net | Select-Object -First 10 | Out-Host
  throw ("STOP: Port {0} still in use after stop (netstat)." -f $Port)
}

Write-Host ("OK: Backend stopped. Port={0} free. (pidfileKilled={1}; portKilled={2})" -f $Port,$killedPidFile,$killedPort) -ForegroundColor Green
