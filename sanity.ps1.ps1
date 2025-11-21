param(
  [int]$ApiPort = 8085,
  [int]$FrontPort = 5177,
  [int]$DbHostPort = 5433
)
$ErrorActionPreference = "Stop"
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

$root  = (Get-Location).Path
$back  = Join-Path $root 'backend'
$front = Join-Path $root 'frontend'

Ok "Project root: $root"

# Docker check (detects the named pipe error too)
try { docker info 1>$null 2>$null; Ok "Docker: OK" }
catch { Fail "Docker is not running. Start Docker Desktop, then retry." }

# Node/npm
try { $node = node -v; Ok "Node $node" } catch { Fail "Node.js not found. Install Node 18+." }
try { $npm = npm -v;  Ok "npm $npm"   } catch { Fail "npm not found." }

# Ports
$ports = @($ApiPort,$FrontPort,$DbHostPort)
$busy = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? { $_.LocalPort -in $ports }
if($busy){ Warn "Ports in use:"; $busy | ft -AutoSize LocalAddress,LocalPort,OwningProcess,State } else { Ok "Ports $($ports -join ', ') are free." }

# Folders
if(!(Test-Path $back)){ Warn "Missing backend folder: $back" } else { Ok "Backend folder present" }
if(!(Test-Path $front)){ Warn "Missing frontend folder: $front" } else { Ok "Frontend folder present" }
