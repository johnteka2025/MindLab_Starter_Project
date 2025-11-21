$ErrorActionPreference = "Stop"
# Confirm DB running
$h = docker inspect -f "{{.State.Health.Status}}" mindlab-db 2>$null
if ($h -ne "healthy") { Write-Host "DB not healthy (state: $h)"; exit 1 }

$stamp = Get-Date -Format "yyyyMMdd_HHmm"
$out = Join-Path (Join-Path $PSScriptRoot "..\backups") "pg_$stamp.sql"

Write-Host "Dumping to $out ..." -ForegroundColor Cyan
# -Fc custom format is also good; we'll use plain SQL for simplicity
docker exec -i mindlab-db pg_dump -U app mindlab | Set-Content $out -Encoding UTF8

if (Test-Path $out) { Write-Host "Backup created: $out" -ForegroundColor Green } else { throw "dump failed" }
