$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# install deps on first run
if (-not (Test-Path .\backend\node_modules)) { pushd .\backend; npm init -y | Out-Null; npm i express cors --silent; popd }
if (-not (Test-Path .\frontend\node_modules)) { pushd .\frontend; npm init -y | Out-Null; popd }

# start backend
$be = Get-Job -Name node-backend -ErrorAction SilentlyContinue
if ($be) { Stop-Job -Name node-backend; Remove-Job -Name node-backend }
Start-Job -Name node-backend -ScriptBlock { Set-Location $using:PSScriptRoot\backend; node .\server.js } | Out-Null

# wait for 8085
$deadline = (Get-Date).AddSeconds(10)
do { Start-Sleep 300; $ok = Test-NetConnection 127.0.0.1 -Port 8085 -InformationLevel Quiet } until ($ok -or (Get-Date) -gt $deadline)
if (-not $ok) { throw "backend failed to start" }

# start frontend
$fe = Get-Job -Name node-frontend -ErrorAction SilentlyContinue
if ($fe) { Stop-Job -Name node-frontend; Remove-Job -Name node-frontend }
Start-Job -Name node-frontend -ScriptBlock { Set-Location $using:PSScriptRoot\frontend; node .\server.js } | Out-Null

# wait for 5177
$deadline = (Get-Date).AddSeconds(10)
do { Start-Sleep 300; $ok = Test-NetConnection 127.0.0.1 -Port 5177 -InformationLevel Quiet } until ($ok -or (Get-Date) -gt $deadline)
if (-not $ok) { throw "frontend failed to start" }

Write-Host "`n=== Sanity ==="
Invoke-RestMethod http://127.0.0.1:8085/health | Out-Host
Write-Host "Open: http://127.0.0.1:5177/"
