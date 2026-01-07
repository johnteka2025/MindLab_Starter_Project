# PHASE2_STEP2_frontend_api_unification_FULL_v3.ps1
# Goal: unify frontend API base usage so ALL calls go through src/api.ts
# Golden Rule: return to project root

$ErrorActionPreference = "Stop"

$ROOT  = "C:\Projects\MindLab_Starter_Project"
$FRONT = Join-Path $ROOT "frontend"
$API   = Join-Path $FRONT "src\api.ts"

Write-Host "============================================================"
Write-Host "PHASE 2 — STEP 2 (v3): Frontend API unification starting"
Write-Host "============================================================"

cd $ROOT
Write-Host "Root: $(Get-Location)"

if (-not (Test-Path $FRONT)) { throw "Missing frontend folder: $FRONT" }
if (-not (Test-Path $API))   { throw "Missing api.ts: $API" }

# 1) Scan frontend/src for hard-coded backend URLs
Write-Host ""
Write-Host "---- Scan frontend/src for hard-coded backend URLs ----"
$hits = Select-String -Path "$FRONT\src\**\*.ts","$FRONT\src\**\*.tsx" -SimpleMatch `
  -Pattern "http://localhost:8085","http://127.0.0.1:8085" -ErrorAction SilentlyContinue

if ($hits) {
  $hits | Select-Object Path, LineNumber, Line | Format-Table -AutoSize
  Write-Host ""
  Write-Host "NOTE: hard-coded URLs found; we'll patch known offenders below (minimal)." -ForegroundColor Yellow
} else {
  Write-Host "OK: No hard-coded backend URLs found in frontend/src" -ForegroundColor Green
}

# 2) Ensure api.ts contains a single exported API_BASE
Write-Host ""
Write-Host "---- Ensure src/api.ts defines API_BASE (single source of truth) ----"

$apiRaw = Get-Content $API -Raw -Encoding UTF8

if ($apiRaw -notmatch 'export\s+const\s+API_BASE') {

  $bakDir = Join-Path $FRONT "backups"
  New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
  $bak = Join-Path $bakDir ("api.ts.bak_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
  Copy-Item $API $bak -Force

  # Build TS prefix as a PowerShell string array (bulletproof; no here-strings)
  $prefixLines = @(
    "/**"
    " * Canonical backend base URL (single source of truth)"
    " * - Prefer VITE_API_BASE_URL if set"
    " * - Default to http://127.0.0.1:8085"
    " */"
    "export const API_BASE ="
    "  (((import.meta as any).env?.VITE_API_BASE_URL?.toString?.() ?? (import.meta as any).env?.VITE_API_BASE_URL)?.toString?.()?.trim?.()"
    "   || 'http://127.0.0.1:8085');"
    ""
    ""
  )

  $prefix = ($prefixLines -join "`r`n")
  Set-Content -Path $API -Value ($prefix + $apiRaw) -Encoding UTF8

  Write-Host "Added API_BASE to api.ts (backup created): $bak" -ForegroundColor Green
} else {
  Write-Host "OK: api.ts already defines API_BASE" -ForegroundColor Green
}

# 3) Patch known offender(s) that might still hardcode base URL
Write-Host ""
Write-Host "---- Patch known offenders (minimal) ----"

$known = @(
  Join-Path $FRONT "src\components\HealthPanel.tsx"
)

foreach ($p in $known) {
  if (-not (Test-Path $p)) {
    Write-Host "Skip (not found): $p"
    continue
  }

  $raw = Get-Content $p -Raw -Encoding UTF8
  $new = $raw

  # Replace hard-coded base URLs with template string using API_BASE
  $new = $new -replace 'fetch\("http:\/\/localhost:8085\/', 'fetch(`${API_BASE}/'
  $new = $new -replace 'fetch\("http:\/\/127\.0\.0\.1:8085\/', 'fetch(`${API_BASE}/'

  if ($new -ne $raw) {
    $bakDir = Join-Path $FRONT "backups"
    New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
    $bak = Join-Path $bakDir ((Split-Path $p -Leaf) + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item $p $bak -Force

    if ($new -notmatch 'import\s+\{\s*API_BASE\s*\}\s+from\s+"\.\.\/api"') {
      # Add import near the top (after first import statement)
      $new = $new -replace '^(import .*?;\s*)', "`$1`r`nimport { API_BASE } from `"../api`";`r`n"
    }

    Set-Content -Path $p -Value $new -Encoding UTF8
    Write-Host "Patched: $p (backup: $bak)" -ForegroundColor Green
  } else {
    Write-Host "No changes needed: $p"
  }
}

# 4) Sanity: frontend typecheck + tests
Write-Host ""
Write-Host "---- Frontend typecheck (no emit) ----"
cd $FRONT
npx tsc -p .\tsconfig.json --noEmit

Write-Host ""
Write-Host "---- Frontend tests ----"
npm test

# Golden Rule
cd $ROOT
Write-Host ""
Write-Host "✅ PHASE 2 — STEP 2 (v3) COMPLETE. Returned to: $(Get-Location)" -ForegroundColor Green
