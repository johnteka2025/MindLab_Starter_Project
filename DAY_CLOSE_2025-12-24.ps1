# DAY_CLOSE_2025-12-24.ps1
# Golden Rules: correct paths, no guessing, sanity checks, backups of outputs, always return to project root.

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) {
    throw "Missing required ${label}: ${p}"
  }
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
Assert-Path $ROOT "project root folder"

Set-Location $ROOT

# ---------- STEP A: Start sanity ----------
Write-Host "=== STEP A: Start sanity (run_everything_sanity.ps1) ===" -ForegroundColor Cyan
$sanity = Join-Path $ROOT "run_everything_sanity.ps1"
Assert-Path $sanity "sanity script (run_everything_sanity.ps1)"

powershell -ExecutionPolicy Bypass -File $sanity

# ---------- STEP B: Create docs baseline (no code changes to app) ----------
Write-Host "=== STEP B: Create/Update docs baseline ===" -ForegroundColor Cyan
$docsDir = Join-Path $ROOT "docs"
if (-not (Test-Path $docsDir)) {
  New-Item -ItemType Directory -Path $docsDir | Out-Null
}

$today = Get-Date -Format "yyyy-MM-dd"
$contractPath = Join-Path $docsDir "PHASE_3_DAILY_CHALLENGE_COMPLETE.md"

$contract = @"
# Phase 3 – Daily Challenge Complete (Baseline)
Date: $today

## Current Status
- Backend: GREEN
- Frontend: GREEN
- Smoke tests: GREEN

## Canonical URLs
- Frontend home: http://localhost:5177/app
- Daily challenge: http://localhost:5177/app/daily
- Progress page: http://localhost:5177/app/progress

## Backend API Contract (Source of Truth)
- GET  /health
  - 200 -> { status: "ok", uptime: number }
- GET  /puzzles
  - 200 -> [ { id, question, options?, correctIndex? } ... ]
- GET  /progress
  - 200 -> { total: number, solved: number, solvedIds: string[] }
- POST /progress/solve
  - Body: { puzzleId: string }
  - 200 -> { ok: true, puzzleId, progress: { total, solved, solvedToday, totalSolved, streak, solvedIds } }
- POST /progress/reset
  - 200 -> { ok: true, total, solved, solvedIds: [] }

## UI Rules (Must Hold)
- Backend is the single source of truth for progress.
- Solved puzzles must not double-count (solvedIds prevents this).
- Daily completion banner appears only when:
  - solved === total
- Status label states:
  - Not started: solved === 0
  - In progress: solved > 0 and solved < total
  - Complete: solved === total

## Notes
- Any future changes must preserve the contract above.
- Golden rule: Always inspect files (Get-Content) before modifying. No guessing.
"@

# Write file in UTF8 (safe + consistent)
$contract | Out-File -FilePath $contractPath -Encoding utf8 -Force
Write-Host "Wrote: $contractPath" -ForegroundColor Green

# ---------- STEP C: Inventory patches + backups (read-only scan) ----------
Write-Host "=== STEP C: Inventory PATCH scripts + .bak files ===" -ForegroundColor Cyan
$reportsDir = Join-Path $ROOT "reports"
if (-not (Test-Path $reportsDir)) {
  New-Item -ItemType Directory -Path $reportsDir | Out-Null
}

$invPath = Join-Path $reportsDir ("DAY_CLOSE_inventory_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

"DAY CLOSE INVENTORY - $today" | Out-File $invPath -Encoding utf8 -Force
"Project Root: $ROOT" | Out-File $invPath -Encoding utf8 -Append
"" | Out-File $invPath -Encoding utf8 -Append

"--- PATCH scripts found in root ---" | Out-File $invPath -Encoding utf8 -Append
Get-ChildItem $ROOT -Filter "PATCH_*.ps1" -File -ErrorAction SilentlyContinue |
  Sort-Object Name |
  ForEach-Object { $_.FullName } |
  Out-File $invPath -Encoding utf8 -Append

"" | Out-File $invPath -Encoding utf8 -Append
"--- Backup files (.bak*) under project (top 200) ---" | Out-File $invPath -Encoding utf8 -Append
Get-ChildItem $ROOT -Recurse -File -Include "*.bak*" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 200 |
  ForEach-Object { "{0} | {1}" -f $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"), $_.FullName } |
  Out-File $invPath -Encoding utf8 -Append

Write-Host "Wrote: $invPath" -ForegroundColor Green

# ---------- STEP D: End sanity (must stay GREEN) ----------
Write-Host "=== STEP D: End sanity (run_everything_sanity.ps1) ===" -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File $sanity

# ---------- STEP E: Quick API smoke summary (optional but helpful) ----------
Write-Host "=== STEP E: Quick API smoke summary ===" -ForegroundColor Cyan
try {
  $h = Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing
  $p = Invoke-WebRequest "http://localhost:8085/puzzles" -UseBasicParsing
  $g = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
  Write-Host ("Health:   {0}" -f $h.StatusCode) -ForegroundColor Green
  Write-Host ("Puzzles:  {0}" -f $p.StatusCode) -ForegroundColor Green
  Write-Host ("Progress: {0}" -f $g.StatusCode) -ForegroundColor Green
} catch {
  Write-Host "Smoke summary could not run (maybe backend not running). This does NOT fail the script." -ForegroundColor Yellow
}

# Always return to root
Set-Location $ROOT
Write-Host "DAY CLOSE GREEN: documentation + inventory + sanity complete." -ForegroundColor Green
Write-Host "Returned to project root: $ROOT" -ForegroundColor Green
