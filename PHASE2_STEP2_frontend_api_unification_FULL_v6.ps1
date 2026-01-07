# PHASE2_STEP2_frontend_api_unification_FULL_v6.ps1
# Goal: unify frontend API base usage via API_BASE in frontend/src/api.ts
# Fix: avoid PowerShell parse errors from quotes inside regex strings.

$ErrorActionPreference = "Stop"

function Write-Section([string]$t) {
  Write-Host ""
  Write-Host ("=" * 78)
  Write-Host $t
  Write-Host ("=" * 78)
}

function Ensure-Dir([string]$p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

function Backup-File([string]$path, [string]$backupDir) {
  Ensure-Dir $backupDir
  $stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
  $leaf = Split-Path $path -Leaf
  $bak  = Join-Path $backupDir ($leaf + ".bak_" + $stamp)
  Copy-Item $path $bak -Force
  return $bak
}

function Get-ApiImportPathFromSrc([string]$fileFullPath, [string]$srcRoot) {
  $fileDir = Split-Path $fileFullPath -Parent
  $relDir  = (Resolve-Path $fileDir).Path
  $srcDir  = (Resolve-Path $srcRoot).Path

  $apiPath = Join-Path $srcDir "api"
  $rel = [IO.Path]::GetRelativePath($relDir, $apiPath)
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
Write-Section "PHASE 2 — STEP 2 (v6): Frontend API base unification"
Write-Host "Root:  $(Get-Location)"

# -------------------------
# A) Ensure API_BASE exists in src/api.ts
# -------------------------
Write-Section "A) Ensure frontend/src/api.ts exports API_BASE (single source of truth)"

$apiTs = Join-Path $SRC "api.ts"
if (-not (Test-Path $apiTs)) { throw "Missing: $apiTs" }

$apiBak = Backup-File $apiTs $BACKUPS
Write-Host "Backed up api.ts -> $apiBak"

$apiRaw = Get-Content $apiTs -Raw -Encoding UTF8

$apiBaseBlock = @'
export const API_BASE =
  ((import.meta as any).env?.VITE_API_BASE_URL?.toString()?.trim() || "http://127.0.0.1:8085")
    .replace(/\/+$/, "");
'@

if ($apiRaw -notmatch 'export\s+const\s+API_BASE\s*=') {
  if ($apiRaw -match '^(import[^\r\n]*\r?\n)+') {
    $apiRaw = $apiRaw -replace '^(import[^\r\n]*\r?\n)+', ('$&' + "`r`n" + $apiBaseBlock + "`r`n")
  } else {
    $apiRaw = $apiBaseBlock + "`r`n`r`n" + $apiRaw
  }
  Set-Content -Path $apiTs -Value $apiRaw -Encoding UTF8
  Write-Host "Inserted API_BASE into api.ts" -ForegroundColor Green
} else {
  Write-Host "API_BASE already present in api.ts (no change)." -ForegroundColor Yellow
}

# -------------------------
# B) Patch hardcoded base URLs in fetch() calls
# -------------------------
Write-Section "B) Patch hardcoded fetch('http://localhost:8085/...') and fetch('http://127.0.0.1:8085/...')"

# Match: fetch("http://localhost:8085/whatever") or fetch('http://127.0.0.1:8085/whatever')
# Capture the path part after :8085 (including /...)
$fetchRx = @'
fetch\(\s*["']http:\/\/(?:localhost|127\.0\.0\.1):8085([^"']*)["']\s*\)
'@.Trim()

# Replace with template-string using API_BASE
$fetchReplacement = 'fetch(`${API_BASE}$1`)'

# IMPORTANT: use DOUBLE-QUOTED regex here (so we can safely include ['\"] without breaking PS)
$importRx = "import\s+\{\s*API_BASE\s*\}\s+from\s+['\"][^'\"]+['\"]"

$targets = Get-ChildItem -Path $SRC -Recurse -File |
  Where-Object { $_.FullName -match '\.(ts|tsx)$' -and $_.FullName -ne $apiTs }

$patchedCount = 0
$skippedNonFetch = 0

foreach ($f in $targets) {
  $raw = Get-Content $f.FullName -Raw -Encoding UTF8

  # Skip if no hardcoded base appears
  if ($raw -notmatch 'http:\/\/(?:localhost|127\.0\.0\.1):8085') { continue }

  $new = $raw -replace $fetchRx, $fetchReplacement

  if ($new -eq $raw) {
    Write-Host "Found base URL but not in fetch('...') format; skipped: $($f.FullName)" -ForegroundColor Yellow
    $skippedNonFetch++
    continue
  }

  $bak = Backup-File $f.FullName $BACKUPS

  # Ensure import exists
  if ($new -notmatch $importRx) {
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

Write-Host ""
Write-Host "Patched files count: $patchedCount" -ForegroundColor Cyan
Write-Host "Skipped (non-fetch URL uses): $skippedNonFetch" -ForegroundColor Cyan

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
Write-Host "✅ PHASE 2 — STEP 2 (v6) COMPLETE. Returned to: $(Get-Location)" -ForegroundColor Green
