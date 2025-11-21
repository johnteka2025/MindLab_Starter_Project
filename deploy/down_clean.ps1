[CmdletBinding()]
param([string]$Network="mindlab-net")
function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green }
docker rm -f mindlab-web mindlab-api 2>$null | Out-Null
docker network rm $Network 2>$null | Out-Null
Ok "Cleaned containers and network (if present)."
