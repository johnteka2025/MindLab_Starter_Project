[CmdletBinding()]
param(
  [int[]]$Ports = @(5177, 8085, 9323),
  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

Info "Port cleanup starting. Target ports: $($Ports -join ', ')"

$targets = @()
foreach($p in $Ports){
  $rows = Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue
  foreach($r in $rows){
    if($null -ne $r.OwningProcess -and $r.OwningProcess -gt 0){
      $targets += [pscustomobject]@{
        Port = $p
        OwningProcess = $r.OwningProcess
      }
    }
  }
}

if(-not $targets -or $targets.Count -eq 0){
  Ok "No target ports are listening. Nothing to stop."
  exit 0
}

Info "Stopping these listeners:"
$targets | Sort-Object Port | Format-Table -AutoSize | Out-Host

$procIds = $targets.OwningProcess | Select-Object -Unique
foreach($procId in $procIds){
  try{
    $proc = Get-Process -Id $procId -ErrorAction Stop
    Warn ("Stopping PID {0} ({1})" -f $procId, $proc.ProcessName)
    Stop-Process -Id $procId -Force:([bool]$Force) -ErrorAction Stop
  } catch {
    Warn ("Could not stop PID {0}: {1}" -f $procId, $_.Exception.Message)
  }
}

Start-Sleep -Seconds 1

$still = @()
foreach($p in $Ports){
  $rows = Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue
  foreach($r in $rows){
    if($null -ne $r.OwningProcess -and $r.OwningProcess -gt 0){
      $still += [pscustomobject]@{ Port=$p; OwningProcess=$r.OwningProcess }
    }
  }
}

if($still.Count -gt 0){
  Warn "Some ports are still listening after cleanup:"
  $still | Sort-Object Port | Format-Table -AutoSize | Out-Host
  exit 2
}

Ok "Port cleanup complete. Target ports are free."
exit 0
