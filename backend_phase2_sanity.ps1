# C:\Projects\MindLab_Starter_Project\backend_phase2_sanity.ps1
$ErrorActionPreference = "Stop"
$projectRoot = "C:\Projects\MindLab_Starter_Project"

try {
  Set-Location $projectRoot

  $health = Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing
  $puzzles = Invoke-WebRequest "http://localhost:8085/puzzles" -UseBasicParsing
  $progress1 = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing

  Write-Host "health   => $($health.StatusCode) $($health.Content)"
  Write-Host "puzzles  => $($puzzles.StatusCode)"
  Write-Host "progress => $($progress1.StatusCode) $($progress1.Content)"

  $solve = Invoke-WebRequest "http://localhost:8085/progress/solve" `
    -Method Post `
    -ContentType "application/json" `
    -Body '{ "puzzleId": "demo-1" }' `
    -UseBasicParsing

  Write-Host "solve    => $($solve.StatusCode) $($solve.Content)"

  $progress2 = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
  Write-Host "progress2=> $($progress2.StatusCode) $($progress2.Content)"
}
finally {
  Set-Location $projectRoot
}
