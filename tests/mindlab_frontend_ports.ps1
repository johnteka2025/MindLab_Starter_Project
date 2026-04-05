param([switch]$NoPause)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location "C:\Projects\MindLab_Starter_Project"

$ports = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 8085,8090 }

$backendCount = @($ports | Where-Object { $_.LocalPort -eq 8085 }).Count
$frontendCount = @($ports | Where-Object { $_.LocalPort -eq 8090 }).Count

if ($backendCount -lt 1 -or $frontendCount -lt 1) {
    throw "Expected ports 8085 and 8090 to be listening."
}

Write-Host "Listening ports:" -ForegroundColor Green
$ports | Format-Table LocalAddress, LocalPort, State, OwningProcess -AutoSize | Out-Host

Set-Location "C:\Projects\MindLab_Starter_Project"

if (-not $NoPause) {
    Read-Host "Press ENTER to keep PowerShell open" | Out-Null
}
