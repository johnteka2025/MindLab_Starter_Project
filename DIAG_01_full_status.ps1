# DIAG_01_full_status.ps1
$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $root)) { throw "Missing project root: $root" }

Write-Host "== Project root ==" -ForegroundColor Cyan
Write-Host $root -ForegroundColor Yellow

Write-Host "`n== Ports listening (PID) ==" -ForegroundColor Cyan
try {
  $conns = Get-NetTCPConnection -State Listen -ErrorAction Stop |
    Where-Object { $_.LocalPort -in 8085,5177 } |
    Sort-Object LocalPort
  if ($conns) {
    $conns | Format-Table -AutoSize LocalAddress,LocalPort,OwningProcess
  } else {
    Write-Host "No listeners found on 8085 or 5177." -ForegroundColor Yellow
  }
} catch {
  Write-Host "Get-NetTCPConnection not available or failed. Skipping port list." -ForegroundColor Yellow
}

Write-Host "`n== Node processes (best-effort) ==" -ForegroundColor Cyan
Get-Process node -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,Path,StartTime | Format-Table -AutoSize

function Test-Endpoint($url) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $url
    Write-Host ("OK  {0}  -> HTTP {1}" -f $url, $r.StatusCode) -ForegroundColor Green
    return $true
  } catch {
    Write-Host ("BAD {0}  -> {1}" -f $url, $_.Exception.Message) -ForegroundColor Red
    return $false
  }
}

Write-Host "`n== Backend endpoint checks ==" -ForegroundColor Cyan
$backendOk = $true
$backendOk = (Test-Endpoint "http://localhost:8085/_runtime") -and $backendOk
$backendOk = (Test-Endpoint "http://localhost:8085/health") -and $backendOk
$backendOk = (Test-Endpoint "http://localhost:8085/puzzles") -and $backendOk
$backendOk = (Test-Endpoint "http://localhost:8085/progress") -and $backendOk

Write-Host "`n== Frontend endpoint checks ==" -ForegroundColor Cyan
$frontendOk = $true
$frontendOk = (Test-Endpoint "http://localhost:5177/app") -and $frontendOk
$frontendOk = (Test-Endpoint "http://localhost:5177/app/daily") -and $frontendOk
$frontendOk = (Test-Endpoint "http://localhost:5177/app/progress") -and $frontendOk

Write-Host "`n== SUMMARY ==" -ForegroundColor Cyan
Write-Host ("Backend OK:  {0}" -f $backendOk) -ForegroundColor Yellow
Write-Host ("Frontend OK: {0}" -f $frontendOk) -ForegroundColor Yellow

Write-Host "`nNext:" -ForegroundColor Cyan
Write-Host "If Backend OK is False -> run RESET_01_restart_clean.ps1 (next step)." -ForegroundColor Yellow
Write-Host "If Backend OK is True but UI still shows Failed to fetch -> we will fix frontend base URLs." -ForegroundColor Yellow
