# INV_02_duplicate_server_files.ps1
$root = "C:\Projects\MindLab_Starter_Project\backend\src"
if (-not (Test-Path $root)) { throw "Missing: $root" }

Write-Host "Server-related files under $root" -ForegroundColor Cyan
$items = Get-ChildItem -Path $root -File -Filter "server.*" | Sort-Object Name
$items | Select-Object Name, FullName, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "`nBackups (server.*.bak_*)" -ForegroundColor Cyan
$bak = Get-ChildItem -Path $root -File -Filter "server.*.bak_*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending
$bak | Select-Object Name, FullName, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "`nIf you want to quarantine old variants, we will move them to backend\src\_quarantine (not delete)." -ForegroundColor Yellow
