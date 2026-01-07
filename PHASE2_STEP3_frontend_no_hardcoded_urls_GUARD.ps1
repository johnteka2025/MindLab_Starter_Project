# PHASE2_STEP3_frontend_no_hardcoded_urls_GUARD.ps1
# Purpose: Fail fast if any hardcoded backend URLs exist in ACTIVE frontend/src files
# Excludes: *.bak_* files and any "backups" directories
# Golden Rule: always return to project root

$ErrorActionPreference = 'Stop'

$ROOT  = 'C:\Projects\MindLab_Starter_Project'
$FRONT = Join-Path $ROOT 'frontend'
$SRC   = Join-Path $FRONT 'src'

function Fail([string]$msg) {
  Write-Host ''
  Write-Host ('FAIL: ' + $msg) -ForegroundColor Red
  throw $msg
}

Write-Host '============================================================'
Write-Host 'PHASE 2 — STEP 3: Frontend hardcoded URL guard (ACTIVE files only)'
Write-Host '============================================================'

Set-Location $ROOT
Write-Host ('Root: ' + (Get-Location))

if (-not (Test-Path $FRONT)) { Fail ('Frontend folder not found: ' + $FRONT) }
if (-not (Test-Path $SRC))   { Fail ('Frontend src folder not found: ' + $SRC) }

# Patterns we never want in ACTIVE frontend/src
$patterns = @(
  'http://localhost:8085',
  'http://127.0.0.1:8085',
  'localhost:8085',
  '127.0.0.1:8085'
)

Write-Host ''
Write-Host 'Scanning ACTIVE frontend/src files (excluding *.bak_* and backups/)...' -ForegroundColor Cyan

# Build file list (ACTIVE only)
$allFiles = Get-ChildItem -Path $SRC -Recurse -File -ErrorAction Stop

$files = $allFiles | Where-Object {
  $_.FullName -notmatch '\\backups\\' -and
  $_.Name     -notmatch '\.bak_'     -and
  $_.Extension -match '^\.(ts|tsx|js|jsx|mjs|cjs|json|css|scss|html)$'
}

$foundAny = $false

foreach ($pat in $patterns) {
  $matches = $files | Select-String -Pattern $pat -AllMatches -ErrorAction SilentlyContinue
  if ($matches) {
    if (-not $foundAny) {
      $foundAny = $true
      Write-Host ''
      Write-Host 'HARD-CODED BACKEND URL(S) FOUND in ACTIVE SOURCE. Fix required.' -ForegroundColor Red
      Write-Host '------------------------------------------------------------' -ForegroundColor Red
    }

    Write-Host ''
    Write-Host ('Pattern: ' + $pat) -ForegroundColor Yellow
    foreach ($m in $matches) {
      Write-Host ('{0}:{1}: {2}' -f $m.Path, $m.LineNumber, $m.Line.Trim())
    }
  }
}

if ($foundAny) {
  Fail 'Hardcoded URL guard failed.'
}

Write-Host 'PASS: No hardcoded backend URLs found in ACTIVE frontend/src files.' -ForegroundColor Green

# Golden Rule
Set-Location $ROOT
Write-Host ('Returned to: ' + (Get-Location))