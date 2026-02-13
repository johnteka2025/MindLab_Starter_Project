param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("start","stop")]
  [string]$Mode,

  [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project",
  [string]$BackendDir = "C:\Projects\MindLab_Starter_Project\backend",

  [string]$HealthUrl = "http://localhost:3000/health",
  [int]$HealthTimeoutSeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Stop-Line([string]$m){
  Write-Host $m -ForegroundColor Red
  $global:LASTEXITCODE = 1
  return $false
}

function Ok-Line([string]$m){
  Write-Host $m -ForegroundColor Green
  $global:LASTEXITCODE = 0
  return $true
}

function Info([string]$m){
  Write-Host $m -ForegroundColor Cyan
}

function Wait-ForHealth([string]$Url,[int]$TimeoutSec){
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
  if (-not (Test-Path (Join-Path $RepoRoot ".git"))) { Stop-Line "STOP: RepoRoot invalid (.git missing)." | Out-Null; return }
  if (-not (Test-Path $BackendDir)) { Stop-Line "STOP: BackendDir missing." | Out-Null; return }

  $pidFile = Join-Path $RepoRoot "tools\.backend_pid"
  $logFile = Join-Path $RepoRoot "tools\.backend_log.txt"

  if ($Mode -eq "start") {
    Info "=== START BACKEND ==="

    if (Test-Path $pidFile) {
      $backendPid = (Get-Content $pidFile -ErrorAction SilentlyContinue)
      if ($backendPid -and (Get-Process -Id $backendPid -ErrorAction SilentlyContinue)) {
        Ok-Line "OK: Backend already running." | Out-Null
        return
      } else {
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
      }
    }

    $p = Start-Process -FilePath "cmd.exe" `
      -ArgumentList "/d /c npm start 1> `"$logFile`" 2>&1" `
      -WorkingDirectory $BackendDir `
      -WindowStyle Hidden `
      -PassThru

    $p.Id | Set-Content -Encoding ASCII $pidFile

    Info ("PID => {0}" -f $p.Id)
    Info ("HealthUrl => {0}" -f $HealthUrl)

    $ok = Wait-ForHealth -Url $HealthUrl -TimeoutSec $HealthTimeoutSeconds
    if (-not $ok) {
      Stop-Line "STOP: Backend did not become healthy within timeout." | Out-Null
      return
    }

    Ok-Line "OK: Backend started and healthy." | Out-Null
    return
  }

  if ($Mode -eq "stop") {
    Info "=== STOP BACKEND ==="

    if (-not (Test-Path $pidFile)) {
      Ok-Line "OK: No backend PID file (already stopped)." | Out-Null
      return
    }

    $backendPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if (-not $backendPid) {
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
      Ok-Line "OK: PID file empty; treated as stopped." | Out-Null
      return
    }

    $proc = Get-Process -Id $backendPid -ErrorAction SilentlyContinue
    if ($proc) {
      try { Stop-Process -Id $backendPid -Force -ErrorAction SilentlyContinue } catch {}
      Start-Sleep -Seconds 1
    }

    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    Ok-Line "OK: Backend stopped." | Out-Null
    return
  }

  Stop-Line "STOP: Unsupported Mode." | Out-Null
}
catch {
  Stop-Line ("STOP: backend_lifecycle crashed: {0}" -f $_.Exception.Message) | Out-Null
}
