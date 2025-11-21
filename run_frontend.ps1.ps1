param(
  [int]$Port = 5177,
  [string]$ApiBase = "http://127.0.0.1:8085"
)
$ErrorActionPreference = "Stop"
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

$root  = (Get-Location).Path
$front = Join-Path $root 'frontend'
if(!(Test-Path $front)){ Fail "Frontend folder not found: $front" }

Set-Content -Path (Join-Path $front ".env.local") -Encoding UTF8 -Value "VITE_API_BASE=$ApiBase"

Push-Location $front
if(!(Test-Path "node_modules")){ Say "Installing frontend deps ..."; npm ci }
Pop-Location

Say "Starting Vite on :$Port ..."
$args = @("run","dev","--","--port","$Port","--strictPort")
$proc = Start-Process -FilePath "npm" -ArgumentList $args -WorkingDirectory $front -PassThru
$proc.Id | Out-File -FilePath (Join-Path ((Get-Location).Path) 'tools\frontend.pid') -Encoding ascii -Force

Say "Verifying frontend ..."
for($i=0; $i -lt 20; $i++){
  try{
    $r = Invoke-WebRequest "http://127.0.0.1:$Port/" -UseBasicParsing -TimeoutSec 3
    if($r.StatusCode -eq 200){ Ok "Frontend ready at http://127.0.0.1:$Port"; exit 0 }
  }catch{}
  Start-Sleep -Seconds 1
}
Warn "Frontend not reachable yet—see the Vite terminal window."
