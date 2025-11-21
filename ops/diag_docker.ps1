[CmdletBinding()]
param(
  [switch]$FixAll  # clears bad vars at Process, User and Machine scopes (admin recommended)
)

$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest

function ShowVar([string]$name, [string]$scope, [string]$value, [string]$status){
  $color = "White"
  switch ($status) {
    "BAD" { $color = "Red" }
    "OK"  { $color = "Green" }
    "INF" { $color = "Yellow" }
  }
  Write-Host ("{0} ({1}) = {2} [{3}]" -f $name,$scope,$value,$status) -ForegroundColor $color
}

$keys = "HTTP_PROXY","HTTPS_PROXY","ALL_PROXY","NO_PROXY",
        "http_proxy","https_proxy","all_proxy","no_proxy",
        "DOCKER_HOST"

Write-Host "=== Docker / proxy environment (all scopes) ===" -ForegroundColor Cyan

$bad = @()

foreach ($k in $keys){
  foreach ($scope in "Process","User","Machine") {
    $v = [Environment]::GetEnvironmentVariable($k,$scope)
    if (-not $v) { continue }

    if ($k -match "PROXY|DOCKER_HOST") {
      if ($v -notmatch "^[a-zA-Z]+://") {
        ShowVar $k $scope $v "BAD"
        $bad += @{Name=$k; Scope=$scope}
      } else {
        ShowVar $k $scope $v "OK"
      }
    } else {
      ShowVar $k $scope $v "INF"
    }
  }
}

if ($bad.Count -eq 0) {
  Write-Host "`nNo malformed proxy/DOCKER_HOST vars found." -ForegroundColor Green
  return
}

Write-Host "`nMalformed vars (missing scheme like http:// or tcp://):" -ForegroundColor Yellow
$bad | ForEach-Object { Write-Host ("  {0} ({1})" -f $_.Name,$_.Scope) -ForegroundColor Yellow }

if ($FixAll) {
  Write-Host "`n[FIX] Clearing bad vars at all scopes..." -ForegroundColor Cyan
  foreach ($b in $bad) {
    [Environment]::SetEnvironmentVariable($b.Name,$null,$b.Scope)
    Write-Host ("Cleared {0} at scope {1}" -f $b.Name,$b.Scope) -ForegroundColor Green
  }
  Write-Host "`nClose this PowerShell window (and restart Docker Desktop if open)." -ForegroundColor Cyan
} else {
  Write-Host "`nRun this script with -FixAll to clear them automatically." -ForegroundColor Cyan
}
