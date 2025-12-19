# QUARANTINE_01_server_duplicates.ps1
$src = "C:\Projects\MindLab_Starter_Project\backend\src"
$q = Join-Path $src "_quarantine"
if (-not (Test-Path $src)) { throw "Missing: $src" }

New-Item -ItemType Directory -Force -Path $q | Out-Null
Write-Host "Quarantine folder: $q" -ForegroundColor Cyan

# Keep server.cjs (runtime). Move other variants (NOT backups) to quarantine.
$move = @("server.js","server.ts","server.backup.js")

foreach ($name in $move) {
  $p = Join-Path $src $name
  if (Test-Path $p) {
    $dest = Join-Path $q $name
    Move-Item -Force $p $dest
    Write-Host "Moved -> $dest" -ForegroundColor Yellow
  } else {
    Write-Host "Not found (ok): $p" -ForegroundColor DarkGray
  }
}

Write-Host "Done. No files deleted." -ForegroundColor Green
