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

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Fail "Docker CLI not found." }
try { $null = docker info --format '{{json .ServerVersion}}' 2>$null } catch { Fail "Docker daemon not responding." }

function Free([int]$p){ -not (Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue) }
if (-not (Free $ApiPort)) { Fail ("Port {0} busy." -f $ApiPort) }
if (-not (Free $WebPort)) { Fail ("Port {0} busy." -f $WebPort) }
Ok ("Docker running; Ports {0}/{1} free" -f $ApiPort,$WebPort)

Info "Pulling images"
docker pull $ApiImage | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Pull failed: $ApiImage" }
docker pull $WebImage | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Pull failed: $WebImage" }

if (-not (docker network ls --format '{{.Name}}' | Select-String -SimpleMatch $Network)) {
  docker network create $Network | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Cannot create network $Network" }
}

# remove any previous containers
$old = docker ps -a --format '{{.ID}}:{{.Names}}' | Select-String -Pattern '^.*:(mindlab-api|mindlab-web)$'
if ($old) { $ids = ($old | % { $_.ToString().Split(':')[0] }); docker rm -f $ids | Out-Host }

# API
$apiEnv = @("--env","PORT=$ApiPort","--env","HOST=0.0.0.0")
docker run -d --name mindlab-api --restart unless-stopped --network $Network -p ("{0}:{0}" -f $ApiPort) $apiEnv $ApiImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to start mindlab-api" }

$base="http://localhost:$ApiPort"; $healthy=$false; $chosen=$null; $deadline=(Get-Date).AddSeconds($HealthTimeoutSec)
while((Get-Date) -lt $deadline -and -not $healthy){
  foreach($p in $HealthPaths){
    try{ $u="$base$p"; $r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $u; if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){$healthy=$true;$chosen=$p;break}}catch{}
  }
  if(-not $healthy){ Start-Sleep -Seconds 1 }
}
if(-not $healthy){
  Warn "API not healthy. Last 200 logs:"; docker logs --tail 200 mindlab-api | Out-Host
  Fail "API health failed."
}
Ok "API healthy at $base$chosen"

$smoked=$false
foreach($p in $SmokePaths){ try{ $u="$base$p"; $r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $u; if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){ Ok "Smoke OK: GET $p -> $($r.StatusCode)"; $smoked=$true; break } }catch{} }
if(-not $smoked){ Warn "Smoke GETs not successful, but health passed." }

# WEB
$webEnv = @("--env","API_URL=$base","--env","HOST=0.0.0.0","--env","PORT=$WebPort")
docker run -d --name mindlab-web --restart unless-stopped --network $Network -p ("{0}:{0}" -f $WebPort) $webEnv $WebImage | Out-Host
if ($LASTEXITCODE -ne 0) { Fail "Failed to start mindlab-web" }
try{ $ru="http://localhost:$WebPort"; $rr=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $ru; Ok "Web reachable at $ru (HTTP $($rr.StatusCode))" }catch{ Warn "Web root not ready yet." }

Ok "Stack up. API: $base  |  Web: http://localhost:$WebPort"
