# locate_real_routes.ps1 (FIXED)
# Purpose: Find REAL frontend /app/daily implementation file + REAL backend /progress handlers
# Excludes: node_modules, dist, build, static assets, frontend assets, backups, *.bak_*, *.backup.*

Write-Host "=== LOCATE REAL ROUTES (FIXED) ===" -ForegroundColor Cyan

$root = "C:\Projects\MindLab_Starter_Project"
$frontend = "$root\frontend"
$backend  = "$root\backend"

if (-not (Test-Path $frontend)) { throw "Missing frontend folder: $frontend" }
if (-not (Test-Path $backend))  { throw "Missing backend folder:  $backend" }

function Get-RealFiles([string]$base, [string[]]$includePatterns) {
  Get-ChildItem -Path $base -Recurse -File -Include $includePatterns -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch "\\node_modules\\" -and
      $_.FullName -notmatch "\\dist\\" -and
      $_.FullName -notmatch "\\build\\" -and
      $_.FullName -notmatch "\\static\\assets\\" -and
      $_.FullName -notmatch "\\frontend\\assets\\" -and
      $_.FullName -notmatch "\\frontend\\backups\\" -and
      $_.Name -notmatch "\.backup\." -and
      $_.Name -notmatch "\.bak_" -and
      $_.Name -notmatch "\.backup_" -and
      $_.Name -notlike "*server.backup*" -and
      $_.Name -notlike "*.backup.*"
    }
}

# ---------- FRONTEND: /app/daily route file ----------
Write-Host "`n[1/3] FRONTEND: Locate /app/daily route (src/App.tsx preferred)" -ForegroundColor Yellow
$appTsx = "$frontend\src\App.tsx"
if (-not (Test-Path $appTsx)) { throw "Missing file: $appTsx" }

$dailyRefs = Select-String -Path $appTsx -Pattern "/app/daily" -SimpleMatch -ErrorAction SilentlyContinue
if ($dailyRefs) {
  Write-Host "Found /app/daily in:" -ForegroundColor Green
  Write-Host $appTsx -ForegroundColor Cyan
  $dailyRefs | ForEach-Object { Write-Host ("Line " + $_.LineNumber + ": " + $_.Line) }
} else {
  Write-Host "No /app/daily in App.tsx; searching frontend src..." -ForegroundColor Yellow
  $srcFiles = Get-RealFiles "$frontend\src" @("*.ts","*.tsx","*.js","*.jsx")
  $hits = $srcFiles | Select-String -Pattern "/app/daily" -SimpleMatch -ErrorAction SilentlyContinue |
    Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber
  if (-not $hits) { throw "Could not find /app/daily route in frontend src." }
  $hits | Format-Table -AutoSize
}

# Extract likely element/component name from the route line
$dailyRouteLine = ($dailyRefs | Select-Object -First 1).Line
$componentGuess = $null
if ($dailyRouteLine -match "element=\{\<([A-Za-z0-9_]+)") {
  $componentGuess = $Matches[1]
}

Write-Host "`n[2/3] FRONTEND: Locate the file implementing the /app/daily page" -ForegroundColor Yellow
if ($componentGuess) {
  Write-Host "Component referenced by /app/daily appears to be: $componentGuess" -ForegroundColor Green
} else {
  Write-Host "Could not parse component name from route line; will search for Daily Challenge heading." -ForegroundColor Yellow
}

$srcFiles = Get-RealFiles "$frontend\src" @("*.ts","*.tsx","*.js","*.jsx")

# Prefer searching by component name if we got it
if ($componentGuess) {
  $compHits = $srcFiles | Select-String -Pattern ("function " + $componentGuess) -SimpleMatch -ErrorAction SilentlyContinue |
    Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber

  if (-not $compHits) {
    $compHits = $srcFiles | Select-String -Pattern ("export default function " + $componentGuess) -SimpleMatch -ErrorAction SilentlyContinue |
      Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber
  }

  if ($compHits) {
    Write-Host "Likely implementing file(s) for component:" -ForegroundColor Green
    $compHits | Format-Table -AutoSize
  } else {
    Write-Host "Could not find component definition by name; falling back to 'Daily Challenge' heading search." -ForegroundColor Yellow
  }
}

$headingHits = $srcFiles | Select-String -Pattern "Daily Challenge" -SimpleMatch -ErrorAction SilentlyContinue |
  Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber

if ($headingHits) {
  Write-Host "Files containing 'Daily Challenge' (filtered):" -ForegroundColor Green
  $headingHits | Format-Table -AutoSize
} else {
  Write-Host "No 'Daily Challenge' heading found in frontend src (filtered)." -ForegroundColor Yellow
}

# ---------- BACKEND: /progress handlers ----------
Write-Host "`n[3/3] BACKEND: Locate /progress handlers (GET/POST) in real server files" -ForegroundColor Yellow
$backendFiles = Get-RealFiles "$backend\src" @("*.ts","*.js")

# Search explicit "/progress" first
$progressHits = $backendFiles | Select-String -Pattern "/progress" -ErrorAction SilentlyContinue |
  Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber

if (-not $progressHits) {
  Write-Host "No literal '/progress' found in backend src (filtered). Searching for 'progress' keyword..." -ForegroundColor Yellow
  $progressHits = $backendFiles | Select-String -Pattern "progress" -ErrorAction SilentlyContinue |
    Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber
}

if (-not $progressHits) {
  Write-Host "No progress hits in backend src. Expanding search to backend root (filtered)..." -ForegroundColor Yellow
  $backendFiles2 = Get-RealFiles "$backend" @("*.ts","*.js")
  $progressHits = $backendFiles2 | Select-String -Pattern "/progress" -ErrorAction SilentlyContinue |
    Select-Object Path, LineNumber, Line | Sort-Object Path, LineNumber
}

if (-not $progressHits) { throw "Could not find progress handlers in backend (filtered)." }

Write-Host "Backend progress references (filtered):" -ForegroundColor Green
$progressHits | Format-Table -AutoSize

Write-Host "`nDONE. Next actions:" -ForegroundColor Cyan
Write-Host "1) Open frontend src\App.tsx and confirm the /app/daily element component name." -ForegroundColor Cyan
Write-Host "2) Open the backend file listed above that contains app.get('/progress') and app.post('/progress')." -ForegroundColor Cyan
