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

function Tail-Log([string]$Path,[int]$Lines=300){
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
  $npm="C:\Program Files\nodejs\npm.cmd"
  $logs=Join-Path $REPO "tools\logs"
  New-Item -ItemType Directory -Force -Path $logs | Out-Null

  $port=8085
  $base="http://127.0.0.1:$port"

  Stop-NodeOnPort -Port $port

  $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
  $log=Join-Path $logs ("backend_dev_" + $stamp + ".log")
  Write-Host ("LOG: " + $log) -ForegroundColor Cyan

  $cmdLine="cd /d `"$backend`" && set NODE_ENV=test && set PORT=$port && `"$npm`" run dev >> `"$log`" 2>&1"
  Start-Process cmd.exe -ArgumentList @("/c",$cmdLine) | Out-Null

  if(-not (Wait-Health -Base $base)){
    Tail-Log -Path $log -Lines 300
    throw "STOP: /health not reachable."
  }

  Invoke-WebRequest -Method Post "$base/__test__/reset" -UseBasicParsing -TimeoutSec 5 | Out-Null

  cd $backend
  $env:CONTRACT_BASE_URL=$base
  & $npm run test:contract | Out-Host
  if($LASTEXITCODE -ne 0){
    Tail-Log -Path $log -Lines 300
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
