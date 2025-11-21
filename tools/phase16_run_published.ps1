<#  Phase 16 — Run the stack from published images (+ smoke checks)
    Usage (example):
    PS> .\deploy\phase16_run_published.ps1 `
          -ApiImage "ghcr.io/yourorg/mindlab-api:1.0.0" `
          -WebImage "ghcr.io/yourorg/mindlab-web:1.0.0" `
          -ApiPort 8085 -WebPort 5177 -Verbose
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ApiImage,
  [Parameter(Mandatory=$true)][string]$WebImage,
  [int]$ApiPort = 8085,
  [int]$WebPort = 5177,
  [string]$Network = "mindlab-net",
  [int]$HealthTimeoutSec = 120,
  [string[]]$HealthPaths = @("/api/health","/health","/healthz"),
  [string[]]$SmokePaths  = @("/api/health","/api/ping","/health","/healthz")
)

function Fail([string]$m){ throw "STOP: $m" }
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green }

# ---------- STEP 0 — Sanity checks ----------
Info "STEP 0 — Sanity checks"

# 0.1 Docker CLI reachable
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Fail "Docker CLI not found in PATH." }

# 0.2 Docker daemon up
try {
  $null = docker info --format '{{json .ServerVersion}}' 2>$null
} catch {
  Fail "Docker daemon not responding. Start Docker Desktop and retry."
}
Ok "Docker is running"

# 0.3 Logged in? (non-fatal if public images)
try {
  $who = docker info --format '{{.ID}}' 2>$null
  if (-not $who) { Warn "Docker login not detected. If images are private, run: docker login" } else { Ok "Docker context OK" }
} catch { Warn "Could not verify docker login. Continuing..." }

# 0.4 Ensure ports are free
function Test-PortFree([int]$p){
  $busy = (Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue)
  return -not $busy
}
if (-not (Test-PortFree $ApiPort)) { Fail "Port $ApiPort is already in use on host." }
if (-not (Test-PortFree $WebPort)) { Fail "Port $WebPort is already in use on host." }
Ok "Ports $ApiPort and $WebPort are free"

# ---------- STEP 1 — Pull images ----------
Info "STEP 1 — Pulling images"
docker pull $ApiImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to pull $ApiImage" }
docker pull $WebImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to pull $WebImage" }
Ok "Images pulled"

# ---------- STEP 2 — Network ----------
Info "STEP 2 — Network"
if (-not (docker network ls --format '{{.Name}}' | Select-String -SimpleMatch $Network)) {
  docker network create $Network | Out-Host
  if ($LASTEXITCODE -ne 0) { Fail "Unable to create network $Network" }
}
Ok "Network $Network ready"

# ---------- STEP 3 — Stop any old containers ----------
Info "STEP 3 — Stop previous containers (if any)"
$old = docker ps -a --format '{{.ID}}:{{.Names}}' | Select-String -Pattern '^.*:(mindlab-api|mindlab-web)$'
if ($old) {
  $ids = ($old | ForEach-Object { $_.ToString().Split(':')[0] })
  docker rm -f $ids | Out-Host
}
Ok "Old containers cleared"

# ---------- STEP 4 — Run API ----------
Info "STEP 4 — Run API container"
$envApi = @(
  "--env","PORT=$ApiPort",
  "--env","HOST=0.0.0.0"          # important: bind to all interfaces inside container
)
docker run -d --name mindlab-api --restart unless-stopped `
  --network $Network -p "$ApiPort:$ApiPort" $envApi $ApiImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to start mindlab-api" }

# ---------- STEP 5 — Wait for API health ----------
Info "STEP 5 — Wait for API to become healthy (timeout ${HealthTimeoutSec}s)"
$base = "http://localhost:$ApiPort"
$healthy = $false
$chosenPath = $null

$deadline = (Get-Date).AddSeconds($HealthTimeoutSec)
while ((Get-Date) -lt $deadline -and -not $healthy) {
  foreach ($p in $HealthPaths) {
    try {
      $u = "$base$p"
      Write-Verbose "Probing $u"
      $r = Invoke-WebRequest -Method GET -Uri $u -UseBasicParsing -TimeoutSec 10
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
        $healthy = $true; $chosenPath = $p; break
      }
    } catch { Start-Sleep -Milliseconds 500 }
  }
  if (-not $healthy) { Start-Sleep -Seconds 1 }
}

if (-not $healthy) {
  Warn "API never became healthy. Showing last 200 log lines:"
  docker logs --tail 200 mindlab-api | Out-Host

  Warn "Container inspect (ports & health if defined):"
  docker inspect mindlab-api --format '{{json .NetworkSettings.Ports}}' | Out-Host

  Fail "API did not pass health probe. Check logs above; common causes below."
}
Ok "API healthy at $base$chosenPath"

# ---------- STEP 6 — Smoke the API (best-effort) ----------
Info "STEP 6 — Smoke the API"
$smoked = $false
foreach ($p in $SmokePaths) {
  try {
    $u = "$base$p"
    $r = Invoke-WebRequest -Method GET -Uri $u -UseBasicParsing -TimeoutSec 10
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) {
      Ok "Smoke OK: GET $p -> $($r.StatusCode)"
      $smoked = $true
      break
    }
  } catch { }
}
if (-not $smoked) { Warn "Smoke test endpoints not found; continuing because health is OK." }

# ---------- STEP 7 — Run Web ----------
Info "STEP 7 — Run Web container"
# If your web needs API URL env var, expose it here. We point at the host-mapped port.
$apiUrl = $base
$envWeb = @(
  "--env","API_URL=$apiUrl",
  "--env","HOST=0.0.0.0",
  "--env","PORT=$WebPort"
)
docker run -d --name mindlab-web --restart unless-stopped `
  --network $Network -p "$WebPort:$WebPort" $envWeb $WebImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to start mindlab-web" }

# Optional: soft check web root
try {
  $ru = "http://localhost:$WebPort"
  $rr = Invoke-WebRequest -Uri $ru -UseBasicParsing -TimeoutSec 10
  Ok "Web reachable at $ru (HTTP $($rr.StatusCode))"
} catch { Warn "Web did not respond to root GET yet; it may still be warming up." }

# ---------- STEP 8 — Summary ----------
Ok "Stack is up."
Write-Host ""
Write-Host "API URL:  $base" -ForegroundColor Green
Write-Host "WEB URL:  http://localhost:$WebPort" -ForegroundColor Green
Write-Host ""
Write-Host "To see logs:" -ForegroundColor Cyan
Write-Host "  docker logs -f mindlab-api"
Write-Host "  docker logs -f mindlab-web"
Write-Host ""
Write-Host "To stop & clean:" -ForegroundColor Cyan
Write-Host "  docker rm -f mindlab-web mindlab-api"
Write-Host "  docker network rm $Network"
