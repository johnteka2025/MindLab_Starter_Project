$ErrorActionPreference = "Stop"
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }

$root  = (Get-Location).Path
$back  = Join-Path $root 'backend'
$front = Join-Path $root 'frontend'

# Kill listeners on our dev ports
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object { $_.LocalPort -in 8085,5177,5433 } |
  ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

# Remove DB container if Docker is running
$dockerOk = $false
try { docker info 1>$null 2>$null; $dockerOk = $true } catch { }
if($dockerOk){
  try { docker rm -f mindlab-db 2>$null | Out-Null } catch { }
}else{
  Warn "Docker not running; skipped container removal."
}

# Optional: remove node_modules to force clean installs
Remove-Item -Recurse -Force (Join-Path $front 'node_modules') -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $back  'node_modules') -ErrorAction SilentlyContinue

Ok "Clean reset done."
