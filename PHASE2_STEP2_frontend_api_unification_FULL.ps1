# PHASE2_STEP2_frontend_api_unification_FULL.ps1
# Goal: unify frontend API base usage so ALL calls go through src/api.ts
# Golden Rule: return to project root

$ErrorActionPreference = "Stop"

$ROOT = "C:\Projects\MindLab_Starter_Project"
$FRONT = Join-Path $ROOT "frontend"
$API = Join-Path $FRONT "src\api.ts"

Write-Host "============================================================"
Write-Host "PHASE 2 — STEP 2: Frontend API unification starting"
Write-Host "============================================================"
cd $ROOT
Write-Host "Root: $(Get-Location)"

if (-not (Test-Path $API)) { throw "Missing: $API" }

# 1) Find any hard-coded backend URLs in frontend/src
Write-Host ""
Write-Host "---- Scan frontend/src for hard-coded localhost backend URLs ----"
$hits = Select-String -Path "$FRONT\src\**\*.ts","$FRONT\src\**\*.tsx" -SimpleMatch `
  -Pattern "http://localhost:8085","http://127.0.0.1:8085" -ErrorAction SilentlyContinue

if ($hits) {
  $hits | Select-Object Path, LineNumber, Line | Format-Table -AutoSize
  Write-Host ""
  Write-Host "NOTE: We'll patch these to use src/api.ts (API_BASE) rather than hard-coded URLs." -ForegroundColor Yellow
} else {
  Write-Host "OK: No hard-coded backend URLs found in frontend/src" -ForegroundColor Green
}

# 2) Ensure api.ts contains a single exported API_BASE with env override
Write-Host ""
Write-Host "---- Ensure src/api.ts has a single API_BASE ----"

$apiRaw = Get-Content $API -Raw -Encoding UTF8
if ($apiRaw -notmatch "export\s+const\s+API_BASE") {
  # Prepend a canonical API_BASE block (safe + minimal)
  $prefix = @'
/**
 * Canonical backend base URL (single source of truth)
 * - Prefer VITE_API_BASE_URL if set
 * - Default to http://127.0.0.1:8085
 */
export const API_BASE =
  ((import.meta as any).env?.VITE_API_BASE_URL?.toString()?.trim() || "http://127.0.0.1:8085");

'@
  $bakDir = Join-Path $FRONT "backups"
  New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
  $bak = Join-Path $bakDir ("api.ts.bak_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
  Copy-Item $API $bak -Force
  Set-Content -Path $API -Value ($prefix + $apiRaw) -Encoding UTF8
  Write-Host "Added API_BASE to api.ts (backup created): $bak" -ForegroundColor Green
} else {
  Write-Host "OK: api.ts already defines API_BASE" -ForegroundColor Green
}

# 3) Patch common offenders to use API_BASE (only if they exist)
Write-Host ""
Write-Host "---- Patch known files (if present) to avoid hard-coded URLs ----"
$known = @(
  Join-Path $FRONT "src\components\HealthPanel.tsx"
)
foreach ($p in $known) {
  if (Test-Path $p) {
    $raw = Get-Content $p -Raw -Encoding UTF8
    $new = $raw.Replace('fetch("http://localhost:8085/', 'fetch(`${API_BASE}/') `
              .Replace('fetch("http://127.0.0.1:8085/', 'fetch(`${API_BASE}/')
    if ($new -ne $raw) {
      $bakDir = Join-Path $FRONT "backups"
      New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
      $bak = Join-Path $bakDir ((Split-Path $p -Leaf) + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
      Copy-Item $p $bak -Force

      # Ensure API_BASE import exists
      if ($new -notmatch 'from\s+"\.{1,2}\/api"' -and $new -notmatch 'from\s+"\.{1,2}\/api\.ts"') {
        # Add import after React import line if present
        if ($new -match 'import\s+React.*?;\s*') {
          $new = $new -replace '(import\s+React.*?;\s*)', "`$1`r`nimport { API_BASE } from `"../api`";`r`n"
        } else {
          $new = 'import { API_BASE } from "../api";' + "`r`n" + $new
        }
      }

      Set-Content -Path $p -Value $new -Encoding UTF8
      Write-Host "Patched: $p (backup: $bak)" -ForegroundColor Green
    } else {
      Write-Host "No changes needed: $p"
    }
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
Write-Host "✅ PHASE 2 — STEP 2 COMPLETE. Returned to: $(Get-Location)" -ForegroundColor Green
