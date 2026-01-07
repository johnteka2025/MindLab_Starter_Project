# run_everything_sanity.ps1
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$backendRoot  = Join-Path $projectRoot "backend"

function Assert-Dir($p) { if (!(Test-Path $p)) { throw "Missing folder: $p" } }
function Wait-Http200($url, $timeoutSec = 30) {
  $stopwatch = [Diagnostics.Stopwatch]::StartNew()
  while ($stopwatch.Elapsed.TotalSeconds -lt $timeoutSec) {
    try {
      $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 3
      if ($r.StatusCode -eq 200) { return }
    } catch { Start-Sleep -Milliseconds 500 }
  }
  throw "Timeout waiting for 200 OK: $url"
}

try {
  Assert-Dir $projectRoot
  Assert-Dir $frontendRoot
  Assert-Dir $backendRoot

  # Kill ports if occupied
  foreach ($p in @(5177,8085)) {
    Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue |
      ForEach-Object { try { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue } catch {} }
  }

  # Start backend
  Set-Location $backendRoot
  Start-Process powershell -ArgumentList "-NoExit","-Command","cd `"$backendRoot`"; npm run dev"

  # Wait backend healthy
  Set-Location $projectRoot
  Wait-Http200 "http://localhost:8085/health" 45

  # Start frontend
  Set-Location $frontendRoot
  Start-Process powershell -ArgumentList "-NoExit","-Command","cd `"$frontendRoot`"; npm run dev"

  # Print URLs
  Set-Location $projectRoot
  Write-Host ""
  Write-Host "Backend OK:  http://localhost:8085/health"
  Write-Host "Frontend:    http://localhost:5177/app"
  Write-Host "Daily:       http://localhost:5177/app/daily"
  Write-Host "Progress:    http://localhost:5177/app/progress"
  Write-Host ""
}
finally {
  Set-Location $projectRoot
}
