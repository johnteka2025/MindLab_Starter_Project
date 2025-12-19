$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $root "frontend"
if (-not (Test-Path $frontendRoot)) { throw "Missing frontend folder: $frontendRoot" }

Write-Host "`n=== [A] Locate App.tsx (router) ===" -ForegroundColor Cyan
$appTsx = Get-ChildItem -Path $frontendRoot -Recurse -File -Filter "App.tsx" -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\dist\\" -and $_.FullName -notmatch "\\build\\" } |
  Select-Object -First 1

if ($appTsx) {
  Write-Host "App.tsx:" -ForegroundColor Yellow
  Write-Host $appTsx.FullName -ForegroundColor Green

  Write-Host "`n--- Lines containing 'progress' in App.tsx ---" -ForegroundColor Cyan
  Select-String -Path $appTsx.FullName -Pattern "progress" | Select-Object Path,LineNumber,Line | Format-Table -AutoSize
} else {
  Write-Host "App.tsx not found (ok; route might be defined elsewhere)." -ForegroundColor Yellow
}

Write-Host "`n=== [B] Find Progress UI candidates (source only) ===" -ForegroundColor Cyan
$include = @("*.ts","*.tsx")
$files = Get-ChildItem -Path $frontendRoot -Recurse -File -Include $include -ErrorAction SilentlyContinue |
  Where-Object {
    $_.FullName -notmatch "\\node_modules\\" -and
    $_.FullName -notmatch "\\dist\\" -and
    $_.FullName -notmatch "\\build\\" -and
    $_.FullName -notmatch "\\backups\\"
  }

# Search for strings that usually appear on the Progress page or tests
$patterns = @(
  "Daily Progress",
  "Puzzles solved",
  "Completion",
  "/app/progress",
  "progress-summary",
  "data-testid=.progress"
)

$hits = foreach ($p in $patterns) {
  $files | Select-String -Pattern $p -ErrorAction SilentlyContinue |
    Select-Object @{n="Pattern";e={$p}}, Path, LineNumber, Line
}

if (-not $hits) {
  Write-Host "No Progress-related hits found in frontend source (unexpected)." -ForegroundColor Red
  Write-Host "Tip: confirm your Progress page text in the browser and re-run." -ForegroundColor Yellow
  exit 2
}

$hitsSorted = $hits | Sort-Object Path, LineNumber
$hitsSorted | Format-Table -AutoSize

Write-Host "`n=== [C] Choose the best candidate automatically ===" -ForegroundColor Cyan
# Prefer files that contain "Daily Progress" or "Puzzles solved"
$preferred = $hitsSorted | Where-Object { $_.Pattern -in @("Daily Progress","Puzzles solved") } | Select-Object -First 1
if (-not $preferred) { $preferred = $hitsSorted | Where-Object { $_.Pattern -eq "Completion" } | Select-Object -First 1 }
if (-not $preferred) { $preferred = $hitsSorted | Select-Object -First 1 }

$target = $preferred.Path
Write-Host "Selected target file:" -ForegroundColor Yellow
Write-Host $target -ForegroundColor Green

Write-Host "`nOpening in Notepad..." -ForegroundColor Cyan
notepad $target

Write-Host "`nDONE. If this is NOT the Progress UI file used at runtime, re-run and pick another file from the table." -ForegroundColor Yellow
