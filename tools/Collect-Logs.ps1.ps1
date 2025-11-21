$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$logs = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logs | Out-Null

function Save($name,$content){ $p = Join-Path $logs $name; $content | Out-File -Encoding UTF8 -FilePath $p -Force; "Wrote $p" }

# Docker logs (only if docker is running and container exists)
$dockerOk = $false
try { docker info 1>$null 2>$null; $dockerOk = $true } catch { }
if($dockerOk){
  $cid = docker ps -a --filter "name=mindlab-db" -q
  if($cid){ try { docker logs mindlab-db 2>&1 | Save "db.log" } catch { "No DB logs" | Save "db.log" } }
  else { "DB container not found" | Save "db.log" }
}else{
  "Docker not running" | Save "db.log"
}

# Backend health
try { (Invoke-RestMethod http://127.0.0.1:8085/health -TimeoutSec 2 | ConvertTo-Json -Compress) | Save "health.json" }
catch { "unreachable" | Save "health.json" }

# Frontend status
try {
  $r = Invoke-WebRequest http://127.0.0.1:5177/ -UseBasicParsing -TimeoutSec 2
  ("Status: {0}" -f $r.StatusCode) | Save "frontend.txt"
} catch { "Unreachable" | Save "frontend.txt" }

Write-Host "Collected in: $logs" -ForegroundColor Cyan
