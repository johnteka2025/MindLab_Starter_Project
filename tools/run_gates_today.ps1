Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $TOOLS=Join-Path $REPO "tools"
  $LOGDIR=Join-Path $TOOLS "logs"
  New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null

  # Prefer existing runner(s) if present
  $primary = @(
    Join-Path $TOOLS "run_contracts.ps1"
    Join-Path $TOOLS "run_gates.ps1"
    Join-Path $TOOLS "run_today.ps1"
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1

  if(-not $primary){ throw "STOP: No primary runner found in tools\. Expected one of: run_contracts.ps1, run_gates.ps1, run_today.ps1" }

  Write-Host ("RUNNER: " + $primary) -ForegroundColor Cyan
  & $primary
  if($LASTEXITCODE -ne 0){ throw "STOP: primary runner failed (exit=$LASTEXITCODE)." }

  Write-Host "OK: gates runner complete." -ForegroundColor Green
}catch{ Write-Host $_ -ForegroundColor Red; exit 1 }finally{ Read-Host "Press ENTER to exit" }
