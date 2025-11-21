[CmdletBinding()]
param(
  [string]$Project = "mindlab",
  [string]$BackendService = "backend",
  [int]$HostApiPort = 8085,
  [string]$HealthUrl = "http://localhost:8085/api/health",
  [int]$WaitSeconds = 150
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT

function Get-ComposeCommand {
  $dc = (Get-Command "docker" -ErrorAction SilentlyContinue)
  $dc1 = (Get-Command "docker-compose" -ErrorAction SilentlyContinue)
  if ($dc) { & docker compose version *> $null; if ($LASTEXITCODE -eq 0) { return @{ Cmd="docker"; Args=@("compose") } } }
  if ($dc1){ return @{ Cmd="docker-compose"; Args=@() } }
  throw "Docker Compose not found. Install Docker Desktop."
}
$compose = Get-ComposeCommand

# Validate compose (helps with 'invalid proto:' issues)
& $compose.Cmd @($compose.Args + @("-p",$Project,"config","-q")) *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERROR] Compose config validation failed. See expanded config:" -ForegroundColor Red
  & $compose.Cmd @($compose.Args + @("-p",$Project,"config")) | Out-Host
  exit 11
}

Write-Host "[BACKEND] Up '$BackendService' on host port $HostApiPort" -ForegroundColor Cyan
& $compose.Cmd @($compose.Args + @("-p",$Project,"up","-d",$BackendService))
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] docker compose up failed." -ForegroundColor Red; exit 12 }

Write-Host "`n[BACKEND] docker ps (ports)" -ForegroundColor Yellow
& docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | Out-Host

$deadline = (Get-Date).AddSeconds($WaitSeconds); $healthy = $false
do {
  try { $r = Invoke-WebRequest -UseBasicParsing -Uri $HealthUrl -TimeoutSec 5; if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { $healthy = $true } }
  catch {}
  if (-not $healthy) { Start-Sleep 2; Write-Host "[BACKEND] Waiting for $HealthUrl ..." -ForegroundColor DarkYellow }
} while (-not $healthy -and (Get-Date) -lt $deadline)

if (-not $healthy) {
  Write-Host "[ERROR] Backend did NOT become healthy at $HealthUrl." -ForegroundColor Red
  Write-Host "[HINT] Last 120 log lines:" -ForegroundColor Yellow
  & $compose.Cmd @($compose.Args + @("-p",$Project,"logs","--no-color",$BackendService,"--tail=120")) | Out-Host
  Write-Host "[HINT] Ensure port mapping like '$HostApiPort:CONTAINER_PORT' for service '$BackendService'." -ForegroundColor Yellow
  exit 13
}
Write-Host "[OK] Backend healthy at $HealthUrl" -ForegroundColor Green
