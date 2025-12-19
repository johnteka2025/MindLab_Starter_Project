# verify_progress.ps1
# Confirms POST /progress actually increments solved.

$base = "http://localhost:8085"

Write-Host "Resetting progress (optional)..." -ForegroundColor Cyan
try {
  Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress/reset" | Out-Null
  Write-Host "Reset OK." -ForegroundColor Green
} catch {
  Write-Host "Reset endpoint not available (OK to ignore)." -ForegroundColor Yellow
}

Write-Host "`nInitial GET /progress:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20

Write-Host "`nPOST correct:true for puzzleId 1" -ForegroundColor Yellow
Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress" -ContentType "application/json" -Body (@{ puzzleId=1; correct=$true } | ConvertTo-Json) | Out-Null

Write-Host "GET /progress after puzzleId 1:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20

Write-Host "`nPOST correct:true for puzzleId 2" -ForegroundColor Yellow
Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress" -ContentType "application/json" -Body (@{ puzzleId=2; correct=$true } | ConvertTo-Json) | Out-Null

Write-Host "GET /progress after puzzleId 2:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20
