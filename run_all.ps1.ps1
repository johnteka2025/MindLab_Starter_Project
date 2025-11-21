param(
  [int]$ApiPort = 8085,
  [int]$FrontPort = 5177,
  [int]$DbHostPort = 5433
)
$ErrorActionPreference = "Stop"
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Fail($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

$root  = (Get-Location).Path
$tools = Join-Path $root 'tools'

# Preflight
& (Join-Path $tools "Sanity.ps1") -ApiPort $ApiPort -FrontPort $FrontPort -DbHostPort $DbHostPort | Out-Host

Say "=== Starting backend ==="
& (Join-Path $tools "Start-Backend.ps1") -ApiPort $ApiPort -DbHostPort $DbHostPort | Out-Host

Say "=== Starting frontend ==="
& (Join-Path $tools "Start-Frontend.ps1") -Port $FrontPort -ApiBase "http://127.0.0.1:$ApiPort" | Out-Host

Ok "`nOpen frontend: http://127.0.0.1:$FrontPort/"
Ok "Backend health: http://127.0.0.1:$ApiPort/health"
