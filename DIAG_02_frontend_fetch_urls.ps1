# DIAG_02_frontend_fetch_urls.ps1
$ErrorActionPreference = "Stop"

$daily = "C:\Projects\MindLab_Starter_Project\frontend\src\pages\Daily.tsx"
$progA = "C:\Projects\MindLab_Starter_Project\frontend\src\pages\Progress.tsx"
$progB = "C:\Projects\MindLab_Starter_Project\frontend\src\progress\ProgressPage.tsx"
$progC = "C:\Projects\MindLab_Starter_Project\frontend\src\pages\ProgressPage.tsx"

Write-Host "== Checking fetch() URLs in key UI files ==" -ForegroundColor Cyan

foreach ($f in @($daily,$progA,$progB,$progC)) {
  if (Test-Path $f) {
    Write-Host "`n--- $f ---" -ForegroundColor Yellow
    $txt = Get-Content $f -Raw
    ($txt | Select-String -Pattern "fetch\(" -AllMatches).Matches.Value | Sort-Object -Unique | ForEach-Object { Write-Host $_ }
    ($txt | Select-String -Pattern "localhost:8085" -AllMatches).Matches.Value | Out-Null
    if ($txt -match "localhost:8085") { Write-Host "Uses localhost:8085 ✅" -ForegroundColor Green } else { Write-Host "Does NOT reference localhost:8085 ❌" -ForegroundColor Red }
  }
}

Write-Host "`nIf Daily/Progress do not reference http://localhost:8085, that explains Failed to fetch." -ForegroundColor Cyan
