Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $TOOLS="$REPO\tools"
  $LOGDIR="$TOOLS\logs"
  $PIDDIR="$TOOLS\pids"
  $PORT=8085
  $STAMP=(Get-Date -Format "yyyyMMdd_HHmmss")
  $outLog="$LOGDIR\backend_dev_$STAMP.out.log"
  $errLog="$LOGDIR\backend_dev_$STAMP.err.log"
  $pidFile="$PIDDIR\backend_dev.pid"

  if(!(Test-Path $BACKEND)){ Stop-With "STOP: missing backend -> $BACKEND" }
  New-Item -ItemType Directory -Force -Path $LOGDIR,$PIDDIR | Out-Null

  # Kill any listener on port
  $conns = netstat -ano | Select-String -Pattern (":$PORT\s+.*LISTENING\s+(\d+)$")
  foreach($m in $conns){
    $parts = ($m.Line -split '\s+') | Where-Object { $_ }
    $listenPid = [int]$parts[-1]
    Stop-Process -Id $listenPid -Force -ErrorAction SilentlyContinue
  }

  Push-Location $BACKEND

  if(!(Test-Path "$BACKEND\node_modules")){
    & cmd.exe /d /c "npm install" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: npm install failed" }
  }

  if(!(Test-Path "$BACKEND\node_modules\.bin\nodemon.cmd")){
    & cmd.exe /d /c "npm install --save-dev nodemon" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: nodemon install failed" }
  }

  Pop-Location

  $p = Start-Process -FilePath "cmd.exe" -ArgumentList @("/d","/c","npm run dev") -WorkingDirectory $BACKEND -WindowStyle Hidden -PassThru -RedirectStandardOutput $outLog -RedirectStandardError $errLog
  Set-Content -Path $pidFile -Value ($p.Id.ToString()) -Encoding ASCII

  Write-Host ("OK: backend started PID=" + $p.Id) -ForegroundColor Green
  Write-Host ("OUT_LOG=" + $outLog) -ForegroundColor Cyan
  Write-Host ("ERR_LOG=" + $errLog) -ForegroundColor Cyan
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
