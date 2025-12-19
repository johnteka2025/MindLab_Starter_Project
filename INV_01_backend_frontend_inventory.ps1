# INV_01_backend_frontend_inventory.ps1
$root = "C:\Projects\MindLab_Starter_Project"
$backend = Join-Path $root "backend"
$frontend = Join-Path $root "frontend"

function Header($t) { Write-Host "`n==== $t ====" -ForegroundColor Cyan }

if (-not (Test-Path $root)) { throw "Root not found: $root" }
if (-not (Test-Path $backend)) { throw "Backend not found: $backend" }
if (-not (Test-Path $frontend)) { throw "Frontend not found: $frontend" }

Header "PROJECT ROOT"
Get-ChildItem -Path $root -Force | Select-Object Name, FullName | Format-Table -AutoSize

Header "BACKEND package.json (start command)"
$pkg = Join-Path $backend "package.json"
if (-not (Test-Path $pkg)) { throw "Missing backend package.json: $pkg" }
$pkgJson = Get-Content $pkg -Raw | ConvertFrom-Json
$startCmd = $pkgJson.scripts.start
Write-Host "backend\package.json scripts.start =" -ForegroundColor Yellow
Write-Host $startCmd -ForegroundColor Green

Header "BACKEND server candidates (src\server.*)"
Get-ChildItem -Path (Join-Path $backend "src") -File -Filter "server.*" -ErrorAction SilentlyContinue |
  Sort-Object Name |
  Select-Object Name, FullName, Length, LastWriteTime |
  Format-Table -AutoSize

Header "BACKEND route keywords scan (health/puzzles/progress/app)"
$src = Join-Path $backend "src"
$include = @("*.js","*.cjs","*.ts")
$files = Get-ChildItem -Path $src -Recurse -File -Include $include -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch "\\node_modules\\" }

$patterns = @(
  "app.get\(",
  "router.get\(",
  "/health",
  "/puzzles",
  "/progress",
  "/app"
)

$hits = foreach ($p in $patterns) {
  $files | Select-String -Pattern $p -ErrorAction SilentlyContinue |
    Select-Object @{n="Pattern";e={$p}}, Path, LineNumber, Line
}
$hits | Sort-Object Path, LineNumber | Format-Table -AutoSize

Header "FRONTEND key pages"
$daily = Get-ChildItem -Path $frontend -Recurse -File -Filter "Daily.tsx" -ErrorAction SilentlyContinue | Select-Object -First 20 Name, FullName, LastWriteTime
$progress = Get-ChildItem -Path $frontend -Recurse -File -Filter "*Progress*.tsx" -ErrorAction SilentlyContinue | Select-Object -First 20 Name, FullName, LastWriteTime
"Daily.tsx candidates:"; $daily | Format-Table -AutoSize
"Progress page candidates:"; $progress | Format-Table -AutoSize

Header "DONE"
