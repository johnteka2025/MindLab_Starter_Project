# test_progress_write.ps1 (NO curl alias; uses Invoke-RestMethod to avoid prompts)

$method = "POST"
$url    = "http://localhost:8085/progress"

# Change puzzleId/correct to test different cases
$payload = @{
  puzzleId = 1
  correct  = $true
}

Write-Host "Sending progress write..." -ForegroundColor Cyan
Write-Host "$method $url" -ForegroundColor Yellow
$payload | ConvertTo-Json -Depth 10 | Write-Host

try {
  $resp = Invoke-RestMethod -TimeoutSec 15 -Method $method -Uri $url -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)
  Write-Host "Progress write OK." -ForegroundColor Green
  Write-Host "Response:" -ForegroundColor Green
  $resp | ConvertTo-Json -Depth 20
} catch {
  Write-Host "Progress write FAILED. Error below:" -ForegroundColor Red
  throw
}

Write-Host "`nNow checking GET /progress..." -ForegroundColor Cyan
try {
  $p = Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "http://localhost:8085/progress"
  Write-Host "GET /progress OK." -ForegroundColor Green
  $p | ConvertTo-Json -Depth 20
} catch {
  Write-Host "GET /progress FAILED." -ForegroundColor Red
  throw
}
