Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Stop-NodeOnPort([int]$Port){
  $conns = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq $Port }
  foreach($c in $conns){
    $pidOnPort = $c.OwningProcess
    $p = Get-Process -Id $pidOnPort -ErrorAction SilentlyContinue
    if($p -and $p.ProcessName -match "node"){
      Stop-Process -Id $pidOnPort -Force -ErrorAction SilentlyContinue
    }
  }
}

function Wait-Health([string]$Base,[int]$Tries=80){
  for($i=1;$i -le $Tries;$i++){
    try{
      $h=Invoke-WebRequest "$Base/health" -UseBasicParsing -TimeoutSec 1
      if($h.StatusCode -eq 200){ return $true }
    } catch {}
    Start-Sleep -Milliseconds 500
  }
  return $false
}

function Tail-Log([string]$Path,[int]$Lines=250){
  if(Test-Path $Path){
    Write-Host ("--- LAST " + $Lines + " LINES: " + $Path + " ---") -ForegroundColor Cyan
    Get-Content $Path -Tail $Lines | Out-Host
  } else {
    Write-Host ("LOG MISSING: " + $Path) -ForegroundColor Yellow
  }
}

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $backend=Join-Path $REPO "backend"
  $logs=Join-Path $REPO "tools\logs"
  New-Item -ItemType Directory -Force -Path $logs | Out-Null

  $port=8085
  $base="http://127.0.0.1:$port"

  Stop-NodeOnPort -Port $port

  $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
  $log=Join-Path $logs ("backend_dev_" + $stamp + ".log")
  Write-Host ("LOG: " + $log) -ForegroundColor Cyan

  $node=(Get-Command node -ErrorAction Stop).Source
  if(-not (Test-Path $node)){ throw "STOP: node not found." }

  $server=Join-Path $backend "src\server.cjs"
  if(-not (Test-Path $server)){ throw "STOP: Missing server => $server" }

  $env:NODE_ENV="test"
  $env:PORT="$port"

  # Start backend directly (NO cmd window)
  $p = Start-Process -FilePath $node -ArgumentList @($server) -WorkingDirectory $backend -PassThru -RedirectStandardOutput $log
  if(-not $p){ throw "STOP: failed to start backend." }
  Write-Host ("BACKEND_PID: " + $p.Id) -ForegroundColor Cyan

  if(-not (Wait-Health -Base $base)){
    Tail-Log -Path $log -Lines 250
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    throw "STOP: /health not reachable."
  }
  Write-Host "OK: /health reachable." -ForegroundColor Green

  Invoke-WebRequest -Method Post "$base/__test__/reset" -UseBasicParsing -TimeoutSec 5 | Out-Null
  Write-Host "OK: /__test__/reset posted." -ForegroundColor Green

  cd $backend
  $npm="C:\Program Files\nodejs\npm.cmd"
  if(-not (Test-Path $npm)){ throw "STOP: Missing npm => $npm" }

  $env:CONTRACT_BASE_URL=$base
  & $npm run test:contract | Out-Host
  $code=$LASTEXITCODE

  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue

  if($code -ne 0){
    Tail-Log -Path $log -Lines 250
    throw "STOP: contracts failed."
  }

  Write-Host "OK: contracts green." -ForegroundColor Green
  exit 0
}
catch{
  Write-Host $_ -ForegroundColor Red
  exit 1
}
finally{
  Read-Host "Press ENTER to exit"
}
