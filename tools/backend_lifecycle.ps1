param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("start","stop")]
  [string]$Mode,

  [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project",
  [string]$BackendDir = "C:\Projects\MindLab_Starter_Project\backend",  [AllowEmptyString()][string]$HealthUrl = "",
  [int]$HealthTimeoutSeconds = 60,

  [switch]$TestMode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  $global:LASTEXITCODE = 1
  return
}
function Ok([string]$m){
  Write-Host $m -ForegroundColor Green
  $global:LASTEXITCODE = 0
  return
}
function Info([string]$m){
  Write-Host $m -ForegroundColor Cyan
}

function Wait-ForHealth([string]$Url,[int]$TimeoutSec){
  if (-not $Url) { return $true } # no health check configured
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    try {
      $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) { return $true }
    } catch {}
    Start-Sleep -Seconds 1
  }
  return $false
}

try {
  if (-not (Test-Path (Join-Path $RepoRoot ".git"))) { Fail "STOP: RepoRoot invalid (.git missing)."; return }
  if (-not (Test-Path $BackendDir)) { Fail "STOP: BackendDir missing."; return }

  $pidFile = Join-Path $RepoRoot "tools\.backend_pid"
  $logFile = Join-Path $RepoRoot "tools\.backend_log.txt"

  if ($Mode -eq "start") {
    Info "=== START BACKEND ==="

    if (Test-Path $pidFile) {
      $backendPid = (Get-Content $pidFile -ErrorAction SilentlyContinue)
      if ($backendPid -and (Get-Process -Id $backendPid -ErrorAction SilentlyContinue)) {
        Ok "OK: Backend already running."
        return
      }
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }

    $cmd = "npm start"
    if ($TestMode) { $cmd = "set MINDLAB_TEST_MODE=1&& npm start" }

    $p = Start-Process -FilePath "cmd.exe" `
      -ArgumentList ("/d /c " + $cmd + " 1> `"$logFile`" 2>&1") `
      -WorkingDirectory $BackendDir `
      -WindowStyle Hidden `
      -PassThru

    $p.Id | Set-Content -Encoding ASCII $pidFile

    Info ("PID => {0}" -f $p.Id)
    if ($TestMode) { Info "MINDLAB_TEST_MODE=1" }
    if ($HealthUrl) { Info ("HealthUrl => {0}" -f $HealthUrl) } else { Info "HealthUrl => (skipped)" }

    $ok = Wait-ForHealth -Url $HealthUrl -TimeoutSec $HealthTimeoutSeconds
    if (-not $ok) { Fail "STOP: Backend did not become healthy within timeout."; return }

    Ok "OK: Backend started."
    return
  }

  if ($Mode -eq "stop") {
    Info "=== STOP BACKEND ==="

    if (-not (Test-Path $pidFile)) { Ok "OK: No backend PID file (already stopped)."; return }

    $backendPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if (-not $backendPid) {
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
      Ok "OK: PID file empty; treated as stopped."
      return
    }

    $proc = Get-Process -Id $backendPid -ErrorAction SilentlyContinue
    if ($proc) {
      try { Stop-Process -Id $backendPid -Force -ErrorAction SilentlyContinue } catch {}
      Start-Sleep -Seconds 1
    }

    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    Ok "OK: Backend stopped."
    return
  }

  Fail "STOP: Unsupported Mode."
}
catch {
  Fail ("STOP: backend_lifecycle crashed: {0}" -f $_.Exception.Message)
}

