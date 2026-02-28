param(
  [ValidateSet("test")]
  [string]$Mode="test",
  [int]$BackendPort=8085,
  [int]$FrontendPort=5177,
  [switch]$KillNonNode,
  [switch]$HardCleanRepo
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Pause-Exit { Read-Host "Press ENTER to exit" | Out-Null }
function StopNow([string]$m){ throw ("STOP: " + $m) }

function RepoGate([switch]$Hard){
  $p=git status --porcelain
  $lines=@()
  if($null -ne $p){
    if($p -is [string]){ $lines=@($p -split "`r?`n" | Where-Object { $_ }) } else { $lines=@($p) }
  }
  if($lines.Count -gt 0){
    "DIRTY:" | Out-Host
    $lines | Out-Host
    if(-not $Hard){ StopNow "Repo dirty. Re-run with -HardCleanRepo OR run TASK 6 (revert) intentionally." }

    git reset --hard HEAD | Out-Host
    if($LASTEXITCODE -ne 0){ StopNow "git reset --hard failed" }

    # IMPORTANT: preserve tracked scripts AND ignored logs
    git clean -fdx -e tools/*.ps1 -e tools/logs/ | Out-Host
    if($LASTEXITCODE -ne 0){ StopNow "git clean failed" }
  }
  $p2=git status --porcelain
  if($p2){ StopNow "Repo still dirty after clean" }
  Write-Host "OK: Repo clean." -ForegroundColor Green
}

function KillPorts([int[]]$Ports,[switch]$AllowNonNode){
  foreach($port in $Ports){
    $conns=Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq $port }
    foreach($c in $conns){
      $procId=$c.OwningProcess
      $p=Get-Process -Id $procId -ErrorAction SilentlyContinue
      $pname=if($p){$p.ProcessName}else{"<unknown>"}
      if($p -and $p.ProcessName -match "node"){
        Stop-Process -Id $procId -Force -ErrorAction Stop
      } else {
        if(-not $AllowNonNode){ StopNow "Port $port owned by PID $procId ($pname). Re-run with -KillNonNode." }
        Stop-Process -Id $procId -Force -ErrorAction Stop
      }
    }
  }
  Write-Host "OK: Ports cleared." -ForegroundColor Green
}

function StartBackend([string]$Repo,[string]$Log){
  $b=Join-Path $Repo "backend"
  if(-not (Test-Path $b)){ StopNow "Missing backend folder: $b" }
  Start-Process powershell.exe -ArgumentList @(
    "-NoProfile","-ExecutionPolicy","Bypass",
    "-Command",
    "Set-Location '$b'; `$env:NODE_ENV='test'; npm run dev *>> '$Log'; Read-Host 'Backend window: press ENTER to close'"
  ) | Out-Null
}

function WaitHealth([int]$Port){
  $base="http://127.0.0.1:$Port"
  $ok=$false
  for($i=0;$i -lt 80;$i++){
    try{ $h=Invoke-WebRequest -Uri "$base/health" -TimeoutSec 2 -UseBasicParsing; if($h.StatusCode -eq 200){$ok=$true;break} } catch {}
    Start-Sleep -Milliseconds 500
  }
  if(-not $ok){ StopNow "/health not reachable on $Port" }
  Write-Host "OK: /health 200." -ForegroundColor Green
}

function ResetGate([int]$Port){
  $base="http://127.0.0.1:$Port"
  $r=Invoke-WebRequest -Method Post -Uri "$base/reset" -TimeoutSec 5 -UseBasicParsing
  if($r.StatusCode -ne 204){ StopNow "/reset not 204" }
  Write-Host "OK: /reset 204." -ForegroundColor Green
}

function ContractGate([string]$Repo){
  cd (Join-Path $Repo "backend")
  npm run test:contract | Out-Host
  if($LASTEXITCODE -ne 0){ StopNow "Contract tests failed" }
  Write-Host "OK: contracts green." -ForegroundColor Green
}

try{
  $Repo="C:\Projects\MindLab_Starter_Project"
  cd $Repo
  git rev-parse --show-toplevel | Out-Null
  if($LASTEXITCODE -ne 0){ StopNow "Not a git repo" }

  RepoGate -Hard:$HardCleanRepo
  KillPorts -Ports @($BackendPort,$FrontendPort) -AllowNonNode:$KillNonNode

  $logDir=Join-Path $Repo "tools\logs"
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
  $log=Join-Path $logDir ("backend_test_" + $stamp + ".log")

  StartBackend -Repo $Repo -Log $log
  WaitHealth -Port $BackendPort
  ResetGate -Port $BackendPort
  ContractGate -Repo $Repo

  Write-Host "OK: ALL GATES PASSED." -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red }
finally{ Pause-Exit }
