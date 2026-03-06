Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  Set-Location $REPO

  function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

  $porc = git status --porcelain
  if(-not $porc){
    Write-Host "OK: repo already clean" -ForegroundColor Green
    return
  }

  $bad=@()
  foreach($line in $porc){
    $p = $line.Substring(3).Trim() -replace '\\','/'
    if($p -notlike "tools/logs/*" -and $p -notlike "tools/pids/*" -and $p -notlike "tools/backups/*"){
      $bad += $p
    }
  }

  if($bad.Count -gt 0){
    $porc | Out-Host
    $badText = (($bad | Select-Object -Unique | Sort-Object) -join ", ")
    Stop-With ("STOP: dirty outside tools runtime dirs -> " + $badText)
  }

  & git clean -fd -- tools/logs tools/pids tools/backups | Out-Host
  Write-Host "OK: cleaned tools runtime dirs" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
