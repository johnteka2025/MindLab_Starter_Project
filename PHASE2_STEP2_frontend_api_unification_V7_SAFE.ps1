# PHASE2_STEP2_frontend_api_unification_V7_SAFE.ps1
# Goal: unify frontend API base usage via API_BASE from src/api.ts
# Golden Rule: return to project root at end

$ErrorActionPreference = "Stop"

function Write-Section([string]$title) {
  Write-Host ""
  Write-Host ("=" * 78)
  Write-Host $title
  Write-Host ("=" * 78)
}

function Ensure-Dir([string]$p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

function Backup-File([string]$filePath, [string]$backupDir) {
  Ensure-Dir $backupDir
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $leaf = Split-Path $filePath -Leaf
  $bak  = Join-Path $backupDir ($leaf + ".bak_" + $stamp)
  Copy-Item -Force $filePath $bak
  return $bak
}

function Get-RelativeApiImportPath([string]$filePath, [string]$srcRoot) {
  $dir = Split-Path $filePath -Parent

  # Normalize
  $srcRootN = (Resolve-Path $srcRoot).Path.TrimEnd('\')
  $dirN     = (Resolve-Path $dir).Path.TrimEnd('\')

  if ($dirN -eq $srcRootN) {
    return "./api"
  }

  # Count depth from srcRoot -> file dir
  if (-not $dirN.StartsWith($srcRootN, [System.StringComparison]::OrdinalIgnoreCase)) {
    # Fallback
    return "../api"
  }

  $rel = $dirN.Substring($srcRootN.Length).TrimStart('\')
  if ($rel -eq "") { return "./api" }

  $parts = $rel.Split('\') | Where-Object { $_ -ne "" }
  $up = ("../" * $parts.Count)
  return ($up + "api").TrimEnd('/')
}

# ---------------------------
# Start
# ---------------------------
$ROOT  = "C:\Projects\MindLab_Starter_Project"
$FRONT = Join-Path $ROOT "frontend"
$SRC   = Join-Path $FRONT "src"
$BKP   = Join-Path $FRONT "backups"

Set-Location $ROOT
Write-Host "Root: $(Get-Location)"

Write-Section "PHASE 2 — STEP 2 (V7 SAFE): Unify frontend API base usage"

# ---------------------------
# A) Ensure frontend/src/api.ts exports API_BASE
# ---------------------------
Write-Section "A) Ensure frontend/src/api.ts exports API_BASE (single source of truth)"

$apiTs = Join-Path $SRC "api.ts"
if (-not (Test-Path $apiTs)) {
  throw "Missing file: $apiTs"
}

$apiRaw = Get-Content $apiTs -Raw -Encoding UTF8

# If API_BASE already exists, do nothing. Else inject it at top.
if ($apiRaw -notmatch "export\s+const\s+API_BASE\s*=") {
  $bak = Backup-File $apiTs $BKP

  $inject = @'
export const API_BASE: string =
  ((import.meta as any).env?.VITE_API_BASE_URL ?? "http://127.0.0.1:8085").toString().trim();

'@

  # Prepend API_BASE at the very top, keep rest as-is
  $apiNew = $inject + $apiRaw
  Set-Content -Path $apiTs -Value $apiNew -Encoding UTF8

  Write-Host "Patched: $apiTs (backup: $bak)" -ForegroundColor Green
} else {
  Write-Host "OK: API_BASE already present in src/api.ts" -ForegroundColor Green
}

# ---------------------------
# B) Patch hardcoded fetch base URLs under src
# ---------------------------
Write-Section "B) Replace hardcoded fetch('http://localhost:8085/...') / fetch('http://127.0.0.1:8085/...') with API_BASE"

# Regex: fetch(<quote>http://(localhost|127.0.0.1):8085/
# Captures quote char so we preserve it.
$rx = [regex]'fetch\(\s*([`''"])\s*https?:\/\/(?:localhost|127\.0\.0\.1):8085\/'

$targets = Get-ChildItem -Path $SRC -Recurse -File |
  Where-Object { $_.Extension -in @(".ts", ".tsx") }

$changedCount = 0
foreach ($f in $targets) {
  $p = $f.FullName
  $raw = Get-Content $p -Raw -Encoding UTF8

  if ($rx.IsMatch($raw)) {
    $new = $rx.Replace($raw, 'fetch($1$${API_BASE}/')

    # Only add import if we actually changed something and it's not api.ts itself
    if ($new -ne $raw) {
      $bak = Backup-File $p $BKP

      if ($p -ne $apiTs) {
        if ($new -notmatch 'import\s+\{\s*API_BASE\s*\}\s+from\s+["''][^"'']+["'']') {
          $importPath = Get-RelativeApiImportPath $p $SRC
          $importLine = "import { API_BASE } from `"$importPath`";`r`n"

          # Insert import after any leading BOM/whitespace and after first import block if present
          # Strategy: if file starts with "import", insert after the last contiguous import line block.
          if ($new -match '^(?:\s*import[^\r\n]*\r?\n)+') {
            $m = [regex]::Match($new, '^(?:\s*import[^\r\n]*\r?\n)+')
            $new = $new.Insert($m.Length, $importLine)
          } else {
            $new = $importLine + $new
          }
        }
      }

      Set-Content -Path $p -Value $new -Encoding UTF8
      $changedCount++
      Write-Host "Patched: $p (backup: $bak)" -ForegroundColor Green
    }
  }
}

Write-Host "Files changed: $changedCount" -ForegroundColor Cyan

# ---------------------------
# C) Sanity: Typecheck + tests
# ---------------------------
Write-Section "C) Sanity: frontend typecheck + tests"

Set-Location $FRONT
Write-Host "In: $(Get-Location)"

Write-Host "`n--- Typecheck (no emit) ---"
npx tsc -p .\tsconfig.json --noEmit

Write-Host "`n--- Frontend tests ---"
npm test

# ---------------------------
# Golden Rule
# ---------------------------
Write-Section "D) GOLDEN RULE: return to project root"
Set-Location $ROOT
Write-Host "Returned to: $(Get-Location)" -ForegroundColor Green
Write-Host "✅ PHASE 2 — STEP 2 (V7 SAFE) COMPLETE." -ForegroundColor Green
