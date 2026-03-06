Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  if(-not (Test-Path $REPO)){ Stop-With "STOP: repo missing -> $REPO" }
  Set-Location $REPO
  if(-not (Test-Path ".git")){ Stop-With "STOP: not a git repository" }

  # Preserve source/features. Clean runtime only.
  $runtimeDirs=@(
    "$REPO\tools\logs",
    "$REPO\tools\pids"
  )

  foreach($d in $runtimeDirs){
    if(Test-Path $d){
      Get-ChildItem -Path $d -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } else {
      New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
  }

  # Safe cleanup for runtime junk only
  $junk=@(
    "$REPO\backend\npm-debug.log",
    "$REPO\backend\yarn-error.log"
  )
  foreach($f in $junk){
    if(Test-Path $f){ Remove-Item $f -Force -ErrorAction SilentlyContinue }
  }

  Write-Host "OK: CLEAN_REPO completed (feature files preserved)" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
