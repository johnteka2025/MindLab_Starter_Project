$ErrorActionPreference = "Stop"

$frontendRoot = "C:\Projects\MindLab_Starter_Project\frontend"
$backupRoot   = Join-Path $frontendRoot "backups"

Write-Host "VERIFY: Latest fullcheck backup" -ForegroundColor Cyan
Write-Host "Frontend root: $frontendRoot"
Write-Host "Backup root  : $backupRoot"
Write-Host "----------------------------------------" -ForegroundColor Cyan

if (-not (Test-Path $backupRoot)) {
  throw "Backup root not found: $backupRoot"
}

$latest = Get-ChildItem -Path $backupRoot -Directory |
  Where-Object { $_.Name -like "fullcheck_*" } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $latest) {
  throw "No fullcheck_* folder found under: $backupRoot"
}

$latestPath = $latest.FullName
$scriptsDir = Join-Path $latestPath "scripts"
$testsDir   = Join-Path $latestPath "tests_e2e"

Write-Host "Latest backup: $latestPath" -ForegroundColor Green
Write-Host "Scripts dir  : $scriptsDir"
Write-Host "Tests dir    : $testsDir"
Write-Host ""

if (-not (Test-Path $scriptsDir)) { throw "Missing scripts dir: $scriptsDir" }
if (-not (Test-Path $testsDir))   { throw "Missing tests_e2e dir: $testsDir" }

Write-Host "[LIST] scripts" -ForegroundColor Cyan
Get-ChildItem -Path $scriptsDir -File | Sort-Object Name | Format-Table Name, Length, LastWriteTime

Write-Host ""
Write-Host "[LIST] tests_e2e" -ForegroundColor Cyan
Get-ChildItem -Path $testsDir -File | Sort-Object Name | Format-Table Name, Length, LastWriteTime

# Sanity: confirm key artifacts exist in backup
$expected = @(
  (Join-Path $scriptsDir "run_all.ps1"),
  (Join-Path $scriptsDir "run_game_flow_ui.ps1"),
  (Join-Path $testsDir   "mindlab-game-flow.spec.ts")
)

$missing = @()
foreach ($p in $expected) {
  if (-not (Test-Path $p)) { $missing += $p }
}

Write-Host ""
if ($missing.Count -gt 0) {
  Write-Host "[FAIL] Missing expected files in latest backup:" -ForegroundColor Red
  $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  exit 1
}

Write-Host "[PASS] Latest backup contains key scripts + new spec." -ForegroundColor Green
exit 0
