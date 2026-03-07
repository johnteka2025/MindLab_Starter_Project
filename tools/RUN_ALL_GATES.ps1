Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $TOOLS="$REPO\tools"
  $LOGDIR="$TOOLS\logs"

  if(!(Test-Path $BACKEND)){ Stop-With "STOP: missing backend -> $BACKEND" }

  & "$TOOLS\CLEAN_REPO.ps1"

  Push-Location $BACKEND

  if(!(Test-Path "$BACKEND\node_modules")){
    & cmd.exe /d /c "npm install" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: npm install failed" }
  }

  if(!(Test-Path "$BACKEND\node_modules\.bin\nodemon.cmd")){
    & cmd.exe /d /c "npm install --save-dev nodemon" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: nodemon install failed" }
  }

  & node -c "src\server.cjs"
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (server.cjs)" }

  if(Test-Path "src\routes\daily.cjs"){
    & node -c "src\routes\daily.cjs"
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }
  }

  if(Test-Path "src\engine\dailyPuzzle.cjs"){
    & node -c "src\engine\dailyPuzzle.cjs"
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (dailyPuzzle.cjs)" }
  }

  if(Test-Path "src\engine\answerValidation.cjs"){
    & node -c "src\engine\answerValidation.cjs"
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (answerValidation.cjs)" }
  }

  if(Test-Path "scripts\engine_smoke.cjs"){
    & node -c "scripts\engine_smoke.cjs"
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (engine_smoke.cjs)" }
    & node "scripts\engine_smoke.cjs" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: engine smoke failed" }
  }

  Pop-Location

  if(Test-Path "$TOOLS\BAN_PID_SCAN.ps1"){
    & "$TOOLS\BAN_PID_SCAN.ps1"
  }

  if(Test-Path "$TOOLS\PHASE2_SMOKE.ps1"){
    & "$TOOLS\PHASE2_SMOKE.ps1"
  }

  & "$TOOLS\BACKEND_DEV_STOP.ps1"  | Out-Null
  & "$TOOLS\BACKEND_DEV_START.ps1" | Out-Null

  try{
    & "$TOOLS\HEALTH_CHECK.ps1" | Out-Null
  } catch {
    if(Test-Path $LOGDIR){
      $latest = Get-ChildItem $LOGDIR -Filter "backend_dev_*.err.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
      if($latest){
        Write-Host ("ERR_LOG=" + $latest.FullName) -ForegroundColor Cyan
        Get-Content $latest.FullName -Tail 120 | Out-Host
      }
    }
    throw
  }

  Set-Location $REPO
  $s = git status --porcelain
  if($s){ $s | Out-Host; Stop-With "STOP: repo became dirty after gates" }

  Write-Host "OK: RUN_ALL_GATES PASSED" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
