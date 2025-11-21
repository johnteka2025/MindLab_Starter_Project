[CmdletBinding()]
param(
  [string]$Project = "mindlab",
  [string]$FrontendService = "web",
  [int]$HostWebPort = 5177,
  [string]$WebUrl = "http://localhost:5177",
  [int]$WaitSeconds = 90
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT

function Get-ComposeCmd {
  if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker compose version *> $null
    if ($LASTEXITCODE -eq 0) { return @{Exe="docker"; Args=@("compose")} }
  }
  if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    return @{Exe="docker-compose"; Args=@()}
  }
  throw "Docker Compose not found. Install/start Docker Desktop."
}
$cmp = Get-ComposeCmd

& $cmp.Exe @($cmp.Args + @("-p",$Project,"config","-q")) *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERROR] Compose config validation failed (web)." -ForegroundColor Red
  & $cmp.Exe @($cmp.Args + @("-p",$Project,"config")) | Out-Host
  exit 20
}

Write-Host "[WEB] Up '$FrontendService' on host port $HostWebPort" -ForegroundColor Cyan
& $cmp.Exe @($cmp.Args + @("-p",$Project,"up","-d",$FrontendService))
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] docker compose up failed." -ForegroundColor Red; exit 21 }

Write-Host "`n[WEB] docker ps (ports)" -ForegroundColor Yellow
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | Out-Host

$deadline = (Get-Date).AddSeconds($WaitSeconds); $up = $false
do {
  try { $null = Invoke-WebRequest -UseBasicParsing -Uri $WebUrl -TimeoutSec 5; $up = $true } catch {}
  if (-not $up) { Start-Sleep 2; Write-Host "[WEB] Waiting for $WebUrl ..." -ForegroundColor DarkYellow }
} while (-not $up -and (Get-Date) -lt $deadline)

if ($up) { Write-Host "[OK] Frontend reachable at $WebUrl" -ForegroundColor Green }
else     { Write-Host "[WARN] Frontend not reachable yet at $WebUrl — continue if you only need API tests." -ForegroundColor Yellow }
