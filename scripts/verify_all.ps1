# verify_all.ps1
$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"

Write-Host "== PATH CHECKS ==" -ForegroundColor Cyan
Test-Path $root | Out-Host
Test-Path (Join-Path $root "frontend\package.json") | Out-Host
Test-Path (Join-Path $root "backend\package.json") | Out-Host

Write-Host "`n== BACKEND CHECKS ==" -ForegroundColor Cyan
(Invoke-WebRequest "http://localhost:8085/puzzles" -UseBasicParsing).StatusCode | Out-Host
(Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing).StatusCode | Out-Host
(Invoke-WebRequest "http://localhost:8085/progress/solve" -Method OPTIONS -UseBasicParsing).StatusCode | Out-Host

Write-Host "`n== FRONTEND CHECKS ==" -ForegroundColor Cyan
(Invoke-WebRequest "http://localhost:5177/" -UseBasicParsing).StatusCode | Out-Host
(Invoke-WebRequest "http://localhost:5177/app/daily" -UseBasicParsing).StatusCode | Out-Host
(Invoke-WebRequest "http://localhost:5177/app/progress" -UseBasicParsing).StatusCode | Out-Host
(Invoke-WebRequest "http://localhost:5177/app/solve" -UseBasicParsing).StatusCode | Out-Host

Write-Host "`n== DONE: verify_all.ps1 PASSED ==" -ForegroundColor Green
