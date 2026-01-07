# PHASE2_STEP2_frontend_api_unification_FULL_v4.ps1
# Goal:
#  - Define ONE frontend API base (API_BASE) in frontend/src/api.ts
#  - Remove hardcoded localhost/127.0.0.1:8085 fetch URLs across frontend by switching to template `${API_BASE}...`
#  - Add correct import { API_BASE } from "<relative>/api" where needed
#  - Sanity: typecheck + tests
#  - Golden Rule: return to project root

$ErrorActionPreference = "Stop"

function Write-Section($t) {
  Write-Host ""
  Write-Host ("=" * 78)
  Write-Host $t
  Write-Host ("=" * 78)
}

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

function Backup-File($path, $backupDir) {
  Ensure-Dir $backupDir
  $stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
  $leaf = Split-Path $path -Leaf
  $bak  = Join-Path $backupDir ($leaf + ".bak_" + $stamp)
  Copy-Item $path $bak -Force
  return $bak
}

function Get-ApiImportPathFromSrc($fileFullPath, $srcRoot) {
  # Determine relative import path to src/api from file location
  $fileDir = Split-Path $fileFullPath -Parent
  $relDir  = Resolve-Path $fileDir
  $srcDir  = Resolve-Path $srcRoot

  $rel = [IO.Path]::GetRelativePath($relDir.Path, (Join-Path $srcDir.Path "api"))
  # Convert to TS import style
  $rel = $rel.Replace("\", "/")
  if ($rel -notmatch '^\.' ) { $rel = "./" + $rel }
  return $rel
}

# -------------------------
# Root paths (Golden Rule)
# -------------------------
$ROOT  = "C:\Projects\MindLab_Starter_Project"
$FRONT = Join-Path $ROOT "frontend"
$SRC   = Join-Path $FRONT "src"
$BACKUPS = Join-Path $FRONT "backups"

Set-Location $ROOT
Write-Section "PHASE 2 — STEP 2 (v4): Frontend API base unification"
Write-Host "Root:  $(Get-Location)"

# -------------------------
# A) Ensure API_BASE exists in src/api.ts
# -------------------------
Write-Section "A) Ensure frontend/src/api.ts exports API_BASE (single source of truth)"

$apiTs = Join-Path $SRC "api.ts"
if (-not (Test-Path $apiTs)) {
  throw "Missing: $apiTs"
}

$apiBak = Backup-File $apiTs $BACKUPS
Write-Host "Backed up api.ts -> $apiBak"

$apiRaw = Get-Content $apiTs -Raw -Encoding UTF8

# Insert / normalize API_BASE
# We keep it simple: read VITE_API_BASE_URL (if present), else default to 127.0.0.1:8085
# Also strip trailing slashes.
$apiBaseBlock = @'
export const API_BASE =
  ((import.meta as any).env?.VITE_API_BASE_URL?.toString()?.trim() || "http://127.0.0.1:8085")
    .replace(/\/+$/, "");
'@

if ($apiRaw -notmatch 'export\s+const\s+API_BASE\s*=') {
  # Put API_BASE right after the first import line block (or at top if no imports)
  if ($apiRaw -match '^(import[^\r\n]*\r?\n)+') {
    $apiRaw = $apiRaw -replace '^(import[^\r\n]*\r?\n)+', ('$&' + "`r`n" + $apiBaseBlock + "`r`n")
  } else {
    $apiRaw = $apiBaseBlock + "`r`n`r`n" + $apiRaw
  }
  Set-Content -Path $apiTs -Value $apiRaw -Encoding UTF8
  Write-Host "Inserted API_BASE into api.ts" -ForegroundColor Green
} else {
  # If it exists, do nothing (avoid risky rewrites)
  Write-Host "API_BASE already present in api.ts (no change)." -ForegroundColor Yellow
}

# -------------------------
# B) Patch hardcoded base URLs in frontend src files
# -------------------------
Write-Section "B) Patch hardcoded http://localhost:8085 or http://127.0.0.1:8085 in frontend/src"

# Regex: replace fetch("http://localhost:8085/xyz") or fetch('http://127.0.0.1:8085/xyz')
# with      fetch(`${API_BASE}/xyz`)
# Notes:
#  - We capture the path after :8085 as group 1
#  - Replacement uses $$ to emit a literal $ in regex replacement
$fetchRx = 'fetch\(\s*["'']http:\/\/(?:localhost|127\.0\.0\.1):8085([^"'']*)["'']\s*\)'
$fetchReplacement = 'fetch(`$${API_BASE}$1`)'

# Scan .ts/.tsx under src (excluding api.ts itself)
$targets = Get-ChildItem -Path $SRC -Recurse -File |
  Where-Object { $_.FullName -match '\.(ts|tsx)$' -and $_.FullName -ne $apiTs }

$patchedCount = 0

foreach ($f in $targets) {
  $raw = Get-Content $f.FullName -Raw -Encoding UTF8
  if ($raw -notmatch 'http:\/\/(?:localhost|127\.0\.0\.1):8085') {
    continue
  }

  $new = $raw -replace $fetchRx, $fetchReplacement

  if ($new -eq $raw) {
    # URL exists but not in fetch(...) format we handle—leave it alone to avoid breaking code
    Write-Host "Found base URL in (non-fetch) context, skipped: $($f.FullName)" -ForegroundColor Yellow
    continue
  }

  # Backup
  $bak = Backup-File $f.FullName $BACKUPS

  # Ensure import { API_BASE } exists
  if ($new -notmatch 'import\s+\{\s*API_BASE\s*\}\s+from\s+["''][^"'']+["'']') {
    $importPath = Get-ApiImportPathFromSrc $f.FullName $SRC
    $importLine = "import { API_BASE } from `"$importPath`";`r`n"

    if ($new -match '^(import[^\r\n]*\r?\n)+') {
      $new = $new -replace '^(import[^\r\n]*\r?\n)+', ('$&' + $importLine)
    } else {
      $new = $importLine + $new
    }
  }

  Set-Content -Path $f.FullName -Value $new -Encoding UTF8
  Write-Host "Patched: $($f.FullName) (backup: $bak)" -ForegroundColor Green
  $patchedCount++
}

Write-Host "Patched files count: $patchedCount" -ForegroundColor Cyan

# -------------------------
# C) Sanity: typecheck + tests
# -------------------------
Write-Section "C) Sanity: frontend typecheck + tests"

Set-Location $FRONT

Write-Host "`n--- Typecheck (no emit) ---"
npx tsc -p .\tsconfig.json --noEmit

Write-Host "`n--- Frontend tests ---"
npm test

# -------------------------
# Golden Rule: return to root
# -------------------------
Set-Location $ROOT
Write-Host ""
Write-Host "✅ PHASE 2 — STEP 2 (v4) COMPLETE. Returned to: $(Get-Location)" -ForegroundColor Green
