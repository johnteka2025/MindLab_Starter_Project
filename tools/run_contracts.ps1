Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Stop-NodeOnPort([int]$Port){
  $conns = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq $Port }
  foreach($c in $conns){
    $pidOnPort = $c.OwningProcess
    $p = Get-Process -Id $pidOnPort -ErrorAction SilentlyContinue
    if($p -and $p.ProcessName -match "node"){ Stop-Process -Id $pidOnPort -Force -ErrorAction SilentlyContinue }
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

function Tail([string]$Path,[int]$Lines=200){
  if(Test-Path $Path){
    Write-Host ("--- TAIL " + $Lines + ": " + $Path + " ---") -ForegroundColor Cyan
    Get-Content $Path -Tail $Lines | Out-Host
  } else {
    Write-Host ("MISSING: " + $Path) -ForegroundColor Yellow
  }
}

$backendProc=$null
try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $backend=Join-Path $REPO "backend"
  $logs=Join-Path $REPO "tools\logs"

  $port=8085
  $base="http://127.0.0.1:$port"

  Write-Host "STEP: kill old listeners on 8085" -ForegroundColor Cyan
  Stop-NodeOnPort -Port $port

  $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
  $outLog=Join-Path $logs ("backend_dev_" + $stamp + ".out.log")
  $errLog=Join-Path $logs ("backend_dev_" + $stamp + ".err.log")

  Write-Host ("OUT_LOG: " + $outLog) -ForegroundColor Cyan
  Write-Host ("ERR_LOG: " + $errLog) -ForegroundColor Cyan

  $node=(Get-Command node -ErrorAction Stop).Source
  $server=Join-Path $backend "src\server.cjs"
  if(-not (Test-Path $server)){ throw "STOP: Missing server => $server" }

  $env:NODE_ENV="test"
  $env:PORT="$port"

  Write-Host "STEP: start backend (node server.cjs)" -ForegroundColor Cyan
  $backendProc = Start-Process -FilePath $node -ArgumentList @($server) -WorkingDirectory $backend -PassThru `
    -RedirectStandardOutput $outLog -RedirectStandardError $errLog
  if(-not $backendProc){ throw "STOP: failed to start backend." }

  Write-Host ("BACKEND_PID: " + $backendProc.Id) -ForegroundColor Cyan

  Write-Host "STEP: wait /health" -ForegroundColor Cyan
  if(-not (Wait-Health -Base $base)){
    Tail $outLog 250
    Tail $errLog 250
    throw "STOP: /health not reachable."
  }
  Write-Host "OK: /health reachable." -ForegroundColor Green

  Write-Host "STEP: POST /__test__/reset" -ForegroundColor Cyan
  Invoke-WebRequest -Method Post "$base/__test__/reset" -UseBasicParsing -TimeoutSec 5 | Out-Null
  Write-Host "OK: reset posted." -ForegroundColor Green

  Write-Host "STEP: run contracts" -ForegroundColor Cyan
  cd $backend
  $npm="C:\Program Files\nodejs\npm.cmd"
  if(-not (Test-Path $npm)){ throw "STOP: Missing npm => $npm" }
  $env:CONTRACT_BASE_URL=$base
  & $npm run test:contract | Out-Host
  $code=$LASTEXITCODE

  if($code -ne 0){
    Tail $outLog 250
    Tail $errLog 250
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
  if($backendProc){
    Stop-Process -Id $backendProc.Id -Force -ErrorAction SilentlyContinue
  }
  Read-Host "Press ENTER to exit"
}
