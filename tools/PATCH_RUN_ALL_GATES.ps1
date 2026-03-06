Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $TOOLS="$REPO\tools"
  $RUNALL="$TOOLS\RUN_ALL_GATES.ps1"
  if(!(Test-Path $RUNALL)){ Stop-With "STOP: missing -> $RUNALL" }

  $newLines = @(
    'Set-StrictMode -Version Latest'
    '$ErrorActionPreference="Stop"'
    'function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }'
    ''
    'try{'
    '  $REPO="C:\Projects\MindLab_Starter_Project"'
    '  $BACKEND="$REPO\backend"'
    '  $TOOLS="$REPO\tools"'
    '  $LOGDIR="$TOOLS\logs"'
    ''
    '  & "$TOOLS\CLEAN_REPO.ps1"'
    ''
    '  if(!(Test-Path $BACKEND)){ Stop-With "STOP: missing backend -> $BACKEND" }'
    '  New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null'
    ''
    '  Push-Location $BACKEND'
    '  if(!(Test-Path "$BACKEND\node_modules")){'
    '    & cmd.exe /d /c "npm install" | Out-Host'
    '    if($LASTEXITCODE -ne 0){ Stop-With "STOP: npm install failed" }'
    '  }'
    '  if(!(Test-Path "$BACKEND\node_modules\.bin\nodemon.cmd")){'
    '    & cmd.exe /d /c "npm install --save-dev nodemon" | Out-Host'
    '    if($LASTEXITCODE -ne 0){ Stop-With "STOP: nodemon install failed" }'
    '  }'
    ''
    '  & node -c "src\server.cjs"'
    '  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (server.cjs)" }'
    ''
    '  if(Test-Path "src\routes\daily.cjs"){'
    '    & node -c "src\routes\daily.cjs"'
    '    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }'
    '  }'
    '  Pop-Location'
    ''
    '  & "$TOOLS\BAN_PID_SCAN.ps1"'
    '  & "$TOOLS\PHASE2_SMOKE.ps1"'
    ''
    '  & "$TOOLS\BACKEND_DEV_STOP.ps1"  | Out-Null'
    '  & "$TOOLS\BACKEND_DEV_START.ps1" | Out-Null'
    ''
    '  try{'
    '    & "$TOOLS\HEALTH_CHECK.ps1" | Out-Null'
    '  } catch {'
    '    if(Test-Path $LOGDIR){'
    '      $latest = Get-ChildItem $LOGDIR -Filter "backend_dev_*.err.log" -ErrorAction SilentlyContinue |'
    '        Sort-Object LastWriteTime -Descending | Select-Object -First 1'
    '      if($latest){'
    '        Write-Host ("ERR_LOG=" + $latest.FullName) -ForegroundColor Cyan'
    '        Get-Content $latest.FullName -Tail 120 | Out-Host'
    '      }'
    '    }'
    '    throw'
    '  }'
    ''
    '  Set-Location $REPO'
    '  $s = git status --porcelain'
    '  if($s){ $s | Out-Host; Stop-With "STOP: repo became dirty after gates" }'
    ''
    '  Write-Host "OK: RUN_ALL_GATES PASSED" -ForegroundColor Green'
    '}'
    'catch{ Write-Host $_ -ForegroundColor Red; throw }'
    'finally{ Read-Host "Press ENTER (PowerShell stays open)" }'
  )

  Set-Content -Path $RUNALL -Value $newLines -Encoding UTF8
  Write-Host "OK: RUN_ALL_GATES patched" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
