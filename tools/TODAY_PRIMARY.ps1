Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Stop-With([string]$msg){ Write-Host $msg -ForegroundColor Red; throw $msg }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $TOOLS="$REPO\tools"
  $PORT=8085
  $BASE="http://127.0.0.1:$PORT"

  # Always run from repo root (prevents SYSTEM32 mistakes)
  Set-Location $REPO
  if(-not (Test-Path ".git")){ Stop-With "STOP: not a git repository -> $REPO" }

  # Repo sanity
  $s=git status --porcelain
  if($s){
    $s | Out-Host
    Stop-With "STOP: repo dirty; run CLEAN_REPO task"
  }

  # Critical files
  $files=@(
    "$BACKEND\src\server.cjs",
    "$BACKEND\src\routes\daily.cjs",
    "$TOOLS\RUN_ALL_GATES.ps1",
    "$TOOLS\ONE_BUTTON_GUARD.ps1",
    "$TOOLS\CONTRACT_TEST.ps1",
    "$TOOLS\BAN_PID_SCAN.ps1"
  )
  foreach($f in $files){ if(!(Test-Path $f)){ Stop-With "STOP: missing -> $f" } }

  # Node syntax checks
  & cmd.exe /d /c "cd /d ""$BACKEND"" && node -c ""src\server.cjs"""
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (server.cjs)" }

  & cmd.exe /d /c "cd /d ""$BACKEND"" && node -c ""src\routes\daily.cjs"""
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }

  # Start backend (background) on correct port
  $logDir="$TOOLS\logs"
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
  $outLog="$logDir\backend_$stamp.out.log"
  $errLog="$logDir\backend_$stamp.err.log"

  $p = Start-Process -FilePath "node" -ArgumentList @("$BACKEND\src\server.cjs") -WorkingDirectory $REPO -PassThru `
        -RedirectStandardOutput $outLog -RedirectStandardError $errLog

  # Wait for server readiness
  $ready=$false
  for($i=0;$i -lt 30;$i++){
    try{
      $r=Invoke-WebRequest "$BASE/daily" -UseBasicParsing -TimeoutSec 3
      if($r.StatusCode -eq 200){ $ready=$true; break }
    }catch{}
    Start-Sleep -Seconds 1
  }
  if(-not $ready){
    try{ Stop-Process -Id $p.Id -Force }catch{}
    Write-Host ("OUTLOG="+$outLog) -ForegroundColor Yellow
    Write-Host ("ERRLOG="+$errLog) -ForegroundColor Yellow
    Stop-With "STOP: backend not responding on $BASE (expected port $PORT)"
  }

  # Contract tests + ban scan + gates
  & "$TOOLS\CONTRACT_TEST.ps1"
  & "$TOOLS\BAN_PID_SCAN.ps1"
  & "$TOOLS\RUN_ALL_GATES.ps1"

  # Stop backend
  try{ Stop-Process -Id $p.Id -Force }catch{}

  # Final repo check
  $s2=git status --porcelain
  if($s2){
    $s2 | Out-Host
    Stop-With "STOP: repo became dirty after gates"
  }

  Write-Host "OK: TODAY PRIMARY FLOW PASSED" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red }
finally{ Read-Host "Press ENTER to exit" }
