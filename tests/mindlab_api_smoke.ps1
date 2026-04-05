param([switch]$NoPause)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location "C:\Projects\MindLab_Starter_Project"

$health = Invoke-RestMethod -Uri "http://localhost:8085/health" -Method GET
$score = Invoke-RestMethod -Uri "http://localhost:8085/score" -Method POST -Body '{"sessionId":"api-smoke","scoreDelta":1,"result":"correct"}' -ContentType "application/json"

Write-Host "API smoke test passed." -ForegroundColor Green
$health | Format-List | Out-Host
$score | Format-List | Out-Host

Set-Location "C:\Projects\MindLab_Starter_Project"

if (-not $NoPause) {
    Read-Host "Press ENTER to keep PowerShell open" | Out-Null
}
