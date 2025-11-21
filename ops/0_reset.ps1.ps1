[CmdletBinding()]
param(
  [int[]]$PortsToFree = @(8085, 5177),
  [string]$Project = "mindlab"
)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT
Write-Host "[RESET] Start" -ForegroundColor Cyan

function Get-ComposeCommand {
  $dc = (Get-Command "docker" -ErrorAction SilentlyContinue)
  $dc1 = (Get-Command "docker-compose" -ErrorAction SilentlyContinue)
  if ($dc) { & docker compose version *> $null; if ($LASTEXITCODE -eq 0) { return @{ Cmd="docker"; Args=@("compose") } } }
  if ($dc1){ return @{ Cmd="docker-compose"; Args=@() } }
  throw "Docker Compose not found. Install Docker Desktop."
}

foreach ($p in $PortsToFree) {
  $pids = netstat -ano | Select-String ":$p " | ForEach-Object { ($_ -split '\s+')[-1] } |
          Sort-Object -Unique | Where-Object { $_ -match '^\d+$' }
  foreach ($pid in $pids) { try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } catch {}; Write-Host "[RESET] Freed port $p (PID $pid)" -ForegroundColor Yellow }
}

& docker version *> $null
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Docker CLI not available. Start Docker Desktop." -ForegroundColor Red; exit 1 }

$compose = Get-ComposeCommand
Write-Host "[RESET] docker compose down ($Project)" -ForegroundColor Yellow
$null = (& $compose.Cmd @($compose.Args + @("-p",$Project,"down","--remove-orphans")) 2>&1)

$art = Join-Path $ROOT "tests\.artifacts"
if (Test-Path $art) { Write-Host "[RESET] Deleting artifacts: $art" -ForegroundColor Yellow; Remove-Item $art -Recurse -Force }
New-Item -ItemType Directory -Force -Path $art | Out-Null
Write-Host "[RESET] Done" -ForegroundColor Green
