param([string]$File = "")
$ErrorActionPreference = "Stop"

if (-not $File) {
  $latest = Get-ChildItem (Join-Path $PSScriptRoot "..\backups") -Filter "pg_*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latest) { throw "No backups in .\backups" }
  $File = $latest.FullName
}
if (-not (Test-Path $File)) { throw "file not found: $File" }

Write-Host "Restoring from $File ..." -ForegroundColor Yellow
# Drop & recreate schema (optional) – here simple psql feed:
Get-Content $File -Raw | docker exec -i mindlab-db psql -U app -d mindlab

Write-Host "Restore completed." -ForegroundColor Green
