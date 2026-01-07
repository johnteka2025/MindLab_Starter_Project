# PHASE2_STEP3B_frontend_no_hardcoded_urls_GUARD_FULL.ps1
# Guard: FAIL if ACTIVE frontend/src contains hardcoded backend URLs
# Excludes: *.bak_* and any \backups\ folder

$ErrorActionPreference = "Stop"

function Write-Section([string]$title) {
  Write-Host ""
  Write-Host ("=" * 72)
  Write-Host $title
  Write-Host ("=" * 72)
}

function Fail([string]$msg) {
  Write-Host ""
  Write-Host ("FAIL: " + $msg) -ForegroundColor Red
  exit 1
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
$SRC  = Join-Path $ROOT "frontend\src"

Write-Section "PHASE 2 - STEP 3B: Guard (no hardcoded backend URLs in ACTIVE frontend/src)"
Write-Host ("Root: " + $ROOT)
Write-Host ("Scan: " + $SRC)

Write-Section "A) Preconditions"
if (-not (Test-Path $ROOT)) { Fail ("Root folder not found: " + $ROOT) }
if (-not (Test-Path $SRC))  { Fail ("frontend/src not found: " + $SRC) }

Write-Section "B) Scan ACTIVE TS/TSX files only (exclude backups and *.bak_*)"
$files = Get-ChildItem -Path $SRC -Recurse -File |
  Where-Object {
    ($_.Extension -in ".ts", ".tsx") -and
    ($_.Name -notmatch "\.bak_") -and
    ($_.FullName -notmatch "\\backups\\")
  }

if (-not $files -or $files.Count -eq 0) {
  Fail "No TS/TSX files found under frontend/src. Unexpected."
}

# Patterns to forbid in SOURCE (ACTIVE files)
$patterns = @(
  "http://localhost:8085",
  "http://127.0.0.1:8085",
  "localhost:8085",
  "127.0.0.1:8085"
)

$foundAny = $false
foreach ($pat in $patterns) {
  $matches = $files | Select-String -Pattern $pat -SimpleMatch
  if ($matches) {
    $foundAny = $true
    Write-Host ""
    Write-Host ("HARD-CODED BACKEND URL FOUND: " + $pat) -ForegroundColor Red
    $matches | ForEach-Object {
      Write-Host ($_.Path + ":" + $_.LineNumber + ": " + $_.Line) -ForegroundColor Yellow
    }
  }
}

if ($foundAny) {
  Fail "Hardcoded URL guard failed. Fix required in ACTIVE frontend/src."
}

Write-Host ""
Write-Host "PASS: No hardcoded backend URLs found in ACTIVE frontend/src." -ForegroundColor Green

Write-Section "C) GOLDEN RULE: return to project root"
Set-Location $ROOT
Write-Host ("Returned to: " + (Get-Location)) -ForegroundColor Green
Write-Host "OK: STEP 3B COMPLETE (guard passed)." -ForegroundColor Green
