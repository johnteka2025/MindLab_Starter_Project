Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Stop-With([string]$msg){ Write-Host $msg -ForegroundColor Red; throw $msg }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $TOOLS="$REPO\tools"

  Set-Location $REPO

  # Repo clean (protect tool scripts)
  git restore --worktree --staged .
  git clean -fd -e tools/logs/ -e tools/pids/ -e tools/backups/ -e tools/*.ps1 -e tools/*.psm1
  $s=git status --porcelain
  if($s){ $s | Out-Host; Stop-With "STOP: repo not clean" }

  # Critical files
  $files=@(
    "$REPO\.gitattributes",
    "$TOOLS\ONE_BUTTON_GUARD.ps1",
    "$TOOLS\CONTRACT_TEST.ps1",
    "$REPO\backend\src\routes\daily.cjs",
    "$REPO\backend\src\server.cjs"
  )
  foreach($f in $files){ if(!(Test-Path $f)){ Stop-With "STOP: missing critical file -> $f" } }

  # Node syntax
  & cmd.exe /d /c "cd /d ""$BACKEND"" && node -c ""src\server.cjs"""
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (server.cjs)" }

  & cmd.exe /d /c "cd /d ""$BACKEND"" && node -c ""src\routes\daily.cjs"""
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }

  # Guard + contracts
  & "$TOOLS\ONE_BUTTON_GUARD.ps1"
  & "$TOOLS\CONTRACT_TEST.ps1"

  Write-Host "OK: RUN_ALL_GATES PASSED" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red }
finally{ Read-Host "Press ENTER to exit" }
