Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $PIDFILE="$REPO\tools\pids\backend_dev.pid"
  $PORT=8085

  if(Test-Path $PIDFILE){
    $pidText=(Get-Content $PIDFILE -Raw).Trim()
    if($pidText -match '^\d+$'){
      $backendPid=[int]$pidText
      Stop-Process -Id $backendPid -Force -ErrorAction SilentlyContinue
    }
    Remove-Item $PIDFILE -Force -ErrorAction SilentlyContinue
  }

  $conns = netstat -ano | Select-String -Pattern (":$PORT\s+.*LISTENING\s+(\d+)$")
  foreach($m in $conns){
    $parts = ($m.Line -split '\s+') | Where-Object { $_ }
    $listenPid = [int]$parts[-1]
    Stop-Process -Id $listenPid -Force -ErrorAction SilentlyContinue
  }

  Write-Host "OK: backend stopped" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
