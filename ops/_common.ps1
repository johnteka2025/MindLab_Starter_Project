[CmdletBinding()] param()
$script:ROOT = "C:\Projects\MindLab_Starter_Project"
Set-Location $script:ROOT
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest

function Info($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERROR] $m" -ForegroundColor Red }

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

function Resolve-ComposeArgs([string]$Project){
  # prefer COMPOSE_FILE if valid; else compose.sanitized.yml; else docker-compose.yml
  $args = @()
  if ($env:COMPOSE_FILE) {
    if (Test-Path $env:COMPOSE_FILE) {
      Ok "COMPOSE_FILE -> $($env:COMPOSE_FILE)"
      $args += @("-f",$env:COMPOSE_FILE)
    } else {
      Err "COMPOSE_FILE points to missing file: $($env:COMPOSE_FILE)"; throw
    }
  } elseif (Test-Path ".\compose.sanitized.yml") {
    Ok "Using compose.sanitized.yml"
    $args += @("-f","compose.sanitized.yml")
  } elseif (Test-Path ".\docker-compose.yml") {
    Ok "Using docker-compose.yml"
  } else {
    Err "No compose file found (compose.sanitized.yml or docker-compose.yml)."; throw
  }
  $args + @("-p",$Project)
}

function Show-ProxyEnv {
  $keys = "HTTP_PROXY","HTTPS_PROXY","ALL_PROXY","NO_PROXY","http_proxy","https_proxy","all_proxy","no_proxy","DOCKER_HOST"
  Info "ENV (proxy/host variables):"
  foreach ($k in $keys) {
    $v = [Environment]::GetEnvironmentVariable($k,'Process'); if (-not $v) { $v=[Environment]::GetEnvironmentVariable($k,'User') }; if (-not $v){ $v=[Environment]::GetEnvironmentVariable($k,'Machine') }
    if ($v) { Write-Host ("  {0} = {1}" -f $k,$v) }
  }
}

function Ensure-Compose-Config([string]$Project){
  $cmp = Get-ComposeCmd
  $common = Resolve-ComposeArgs -Project $Project
  Info ("[CHECK] docker {0} {1} config -q" -f ($cmp.Args -join " "), ($common -join " "))
  & $cmp.Exe @($cmp.Args + $common + @("config","-q")) *> $null
  if ($LASTEXITCODE -ne 0) {
    Err "Compose config failed. Likely causes on Windows:"
    Warn "• URL fields must include scheme, e.g., http://localhost:8085"
    Warn "• Ports as 'host:container' quoted:  - `"8085:8080`""
    Warn "• Volumes as POSIX paths:  - /c/Projects/.../backend:/app"
    Warn "• Proxy/DOCKER_HOST vars missing http://"
    Show-ProxyEnv
    throw "compose config failed"
  }
  Ok "Compose config passed."
}

function Free-Port([int]$Port){
  $pids = netstat -ano | Select-String ":$Port\s" | ForEach-Object { ($_ -split '\s+')[-1] } | Sort-Object -Unique
  foreach ($pid in $pids) { try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue; Ok "Killed PID $pid on port $Port" } catch {} }
}
