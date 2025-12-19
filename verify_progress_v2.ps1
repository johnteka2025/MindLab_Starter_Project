$base = "http://localhost:8085"

Write-Host "Server identity:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/__server_id" | ConvertTo-Json -Depth 10

Write-Host "`nReset progress:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress/reset" | ConvertTo-Json -Depth 10

Write-Host "`nInitial /progress:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20

Write-Host "`nPOST puzzleId=1 correct=true" -ForegroundColor Yellow
Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress" -ContentType "application/json" -Body (@{ puzzleId=1; correct=$true } | ConvertTo-Json) | ConvertTo-Json -Depth 20

Write-Host "`nAfter 1:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20

Write-Host "`nPOST puzzleId=2 correct=true" -ForegroundColor Yellow
Invoke-RestMethod -TimeoutSec 15 -Method POST -Uri "$base/progress" -ContentType "application/json" -Body (@{ puzzleId=2; correct=$true } | ConvertTo-Json) | ConvertTo-Json -Depth 20

Write-Host "`nAfter 2:" -ForegroundColor Cyan
Invoke-RestMethod -TimeoutSec 15 -Method GET -Uri "$base/progress" | ConvertTo-Json -Depth 20
