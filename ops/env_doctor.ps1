# env_doctor.ps1  —  PS 5.1-safe environment checker/updater for MindLab
[CmdletBinding()]
param(
  [switch]$UpdateSoftware,   # uses winget to upgrade Docker Desktop, Git, Node LTS (if installed)
  [switch]$FixProxies,       # clears malformed HTTP(S)_PROXY/ALL_PROXY/DOCKER_HOST at User & Process scope
  [switch]$KillPorts,        # kills any process listening on 8085/5177
  [switch]$RemoveLegacyDC    # remove legacy docker-compose.exe from Docker resources bin
)

$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest

function Write-Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err($m){ Write-Host "[ERROR] $m" -ForegroundColor Red }

# ---- 0) Admin check ----
$curr = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $curr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Err "Run this script from an **elevated** PowerShell (Admin)."; exit 1
}

# ---- 1) Report versions ----
function TryRun([string]$exe, [string[]]$args){
  try { & $exe @args 2>$null } catch { return $null }
}
function FirstLine($text){ if ($null -eq $text) { return $null } ($text -split "`r?`n")[0] }

$psv = $PSVersionTable.PSVersion.ToString()
Write-Host "`n=== Versions ===" -ForegroundColor Cyan
Write-Host ("PowerShell:            {0}" -f $psv)

$wing = TryRun "winget" @("--version") | Out-String
if ($wing){ Write-Host ("winget:                {0}" -f (FirstLine $wing)) } else { Write-Warn "winget not found (App Installer). Upgrades will be skipped." }

$dockerInfo  = TryRun "docker" @("version") | Out-String
$dockerOk    = $dockerInfo -and $LASTEXITCODE -eq 0
if ($dockerOk){
  $first = FirstLine $dockerInfo
  Write-Host ("docker:                {0}" -f $first)
} else { Write-Warn "docker CLI not responding. Is Docker Desktop running?" }

$composeV2   = TryRun "docker" @("compose","version") | Out-String
if ($composeV2){ Write-Host ("docker compose v2:    {0}" -f (FirstLine $composeV2)) } else { Write-Warn "Compose v2 not available through 'docker compose'." }

$composeV1   = TryRun "docker-compose" @("version") | Out-String
if ($composeV1){ Write-Host ("docker-compose v1:    {0}" -f (FirstLine $composeV1)) }

$gitV        = TryRun "git" @("--version") | Out-String
if ($gitV){ Write-Host ("git:                   {0}" -f (FirstLine $gitV)) } else { Write-Warn "git not found." }

$nodeV       = TryRun "node" @("--version") | Out-String
if ($nodeV){ Write-Host ("node:                  {0}" -f (FirstLine $nodeV)) } else { Write-Warn "node not found." }

$wslV        = TryRun "wsl" @("--version") | Out-String
if ($wslV){ Write-Host ("wsl:                   {0}" -f (FirstLine $wslV)) } else { Write-Warn "wsl not found or not updated (ok if you don't use WSL)." }

# ---- 2) Minimum version policy ----
$needDockerDesktop = $true
$minComposeMajor   = 2
$minEngineMajor    = 27   # guidance target; informational here

if ($dockerOk){
  # Try to detect engine major (best-effort)
  $engineMajor = ($dockerInfo -split "`n" | Select-String -Pattern "Server:").Line
  # Not strictly parsed—informational only.
}
if ($composeV2){
  if (-not ($composeV2 -match "v(\d+)\.")){ Write-Warn "Could not parse Compose v2 major version." }
  else {
    $maj = [int]$matches[1]
    if ($maj -lt $minComposeMajor){ Write-Err "Compose v2 major <$minComposeMajor. Please update Docker Desktop."; $needDockerDesktop = $true }
    else { Write-Ok "Compose v2 major is $maj (>= $minComposeMajor)" }
  }
} else { Write-Err "Compose v2 missing. Update Docker Desktop."; $needDockerDesktop = $true }

# ---- 3) Optional: Upgrade with winget ----
if ($UpdateSoftware -and $wing){
  Write-Host "`n=== Upgrading with winget (silent) ===" -ForegroundColor Cyan
  $ids = @(
    "Docker.DockerDesktop",
    "Git.Git",
    "OpenJS.NodeJS.LTS"
  )
  foreach ($id in $ids){
    try {
      Write-Host ("winget upgrade --id {0} --silent --accept-source-agreements --accept-package-agreements" -f $id) -ForegroundColor DarkCyan
      winget upgrade --id $id --silent --accept-source-agreements --accept-package-agreements | Out-Null
    } catch {
      Write-Warn "winget failed for $id (may not be installed, or App Installer missing)."
    }
  }
  Write-Ok "winget upgrade pass completed."
}

# ---- 4) Optional: remove legacy docker-compose.exe to avoid v1/v2 conflicts ----
if ($RemoveLegacyDC){
  $legacy = "C:\Program Files\Docker\Docker\resources\bin\docker-compose.exe"
  if (Test-Path $legacy){
    try { Remove-Item $legacy -Force; Write-Ok "Removed legacy $legacy" }
    catch { Write-Warn "Could not remove $legacy (in use or permissions). You may delete it manually." }
  } else { Write-Ok "No legacy docker-compose.exe at the common location." }
}

# ---- 5) Check proxies & DOCKER_HOST ----
Write-Host "`n=== Environment (proxies / DOCKER_HOST) ===" -ForegroundColor Cyan
$keys = "HTTP_PROXY","HTTPS_PROXY","ALL_PROXY","NO_PROXY","http_proxy","https_proxy","all_proxy","no_proxy","DOCKER_HOST"
$bad = @()
foreach ($k in $keys){
  $vProc = [Environment]::GetEnvironmentVariable($k,'Process')
  $vUser = [Environment]::GetEnvironmentVariable($k,'User')
  $vMach = [Environment]::GetEnvironmentVariable($k,'Machine')
  $val = $vProc; if (-not $val) { $val = $vUser }; if (-not $val) { $val = $vMach }
  if ($val) {
    Write-Host ("{0} = {1}" -f $k,$val)
    if (($k -match "PROXY|DOCKER_HOST") -and (-not ($val -match "^[a-zA-Z]+://"))) {
      $bad += $k
    }
  }
}
if ($bad.Count -gt 0){
  Write-Err ("These vars are set **without** protocol (http://…): {0}" -f ($bad -join ", "))
  if ($FixProxies){
    foreach ($k in $bad){
      [Environment]::SetEnvironmentVariable($k,$null,'Process')
      [Environment]::SetEnvironmentVariable($k,$null,'User')
      Write-Ok "Cleared $k at Process & User scope"
    }
  } else {
    Write-Warn "Re-run with -FixProxies to clear them, or set values like 'http://proxy:port'."
  }
} else { Write-Ok "No malformed proxy/DOCKER_HOST vars detected." }

# ---- 6) Compose file selection sanity ----
Write-Host "`n=== Compose file selection ===" -ForegroundColor Cyan
$cf = $env:COMPOSE_FILE
if ($cf){ 
  if (Test-Path $cf){ Write-Ok "COMPOSE_FILE -> $cf" } else { Write-Err "COMPOSE_FILE points to missing file: $cf" }
} elseif (Test-Path ".\compose.sanitized.yml") { Write-Ok "Will use compose.sanitized.yml (if scripts auto-detect)." }
elseif (Test-Path ".\docker-compose.yml")     { Write-Ok "Will use repo docker-compose.yml (if scripts auto-detect)." }
else { Write-Err "No compose file found in current directory." }

# ---- 7) Ports check (and optional cleanup) ----
Write-Host "`n=== Port checks (8085 API, 5177 Web) ===" -ForegroundColor Cyan
function Show-Port($port){
  $hits = (netstat -ano | Select-String ":$port\s").ToString()
  if ($hits){ Write-Warn ("Port {0} in use." -f $port); return $true } else { Write-Ok ("Port {0} free." -f $port); return $false }
}
$inUse8085 = Show-Port 8085
$inUse5177 = Show-Port 5177

if ($KillPorts){
  foreach ($p in 8085,5177){
    $pids = netstat -ano | Select-String ":$p\s" | ForEach-Object { ($_ -split '\s+')[-1] } | Sort-Object -Unique
    foreach ($pid in $pids){ try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue; Write-Ok "Killed PID $pid on port $p" } catch {} }
  }
}

# ---- 8) Docker Desktop readiness ----
Write-Host "`n=== Docker daemon check ===" -ForegroundColor Cyan
try { docker info *> $null; Write-Ok "Docker daemon reachable." }
catch { Write-Err "Docker daemon NOT reachable. Start Docker Desktop, then re-run."; }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "• Versions printed above."
Write-Host "• Compose v2 present: " -NoNewline
if ($composeV2) { Write-Host "YES" -ForegroundColor Green } else { Write-Host "NO" -ForegroundColor Red }
Write-Host "• Proxies valid: " -NoNewline
if ($bad.Count -eq 0) { Write-Host "YES" -ForegroundColor Green } else { Write-Host "NO" -ForegroundColor Red }
Write-Host "• Ports free (8085/5177): " -NoNewline
if (-not $inUse8085 -and -not $inUse5177) { Write-Host "YES" -ForegroundColor Green } else { Write-Host "NO" -ForegroundColor Yellow }
Write-Host "• Compose file selected: " -NoNewline
if ($cf -or (Test-Path ".\compose.sanitized.yml") -or (Test-Path ".\docker-compose.yml")) { Write-Host "YES" -ForegroundColor Green } else { Write-Host "NO" -ForegroundColor Red }

Write-Host "`nDone."
