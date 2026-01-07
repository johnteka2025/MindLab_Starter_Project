# PHASE2_STEP3A_fix_api_base_require_env_FULL.ps1
# Policy: NO hardcoded backend URL in frontend/src
# Goal: api.ts must REQUIRE VITE_API_BASE_URL at runtime (no fallback)

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

# --- Root ---
$ROOT = "C:\Projects\MindLab_Starter_Project"
$FRONT = Join-Path $ROOT "frontend"
$API_FILE = Join-Path $FRONT "src\api.ts"

Write-Section "PHASE 2 - STEP 3A: api.ts require env (no fallback hardcode)"
Write-Host ("Root: " + $ROOT)

Write-Section "A) Preconditions"
if (-not (Test-Path $ROOT)) { Fail ("Root folder not found: " + $ROOT) }
if (-not (Test-Path $FRONT)) { Fail ("Frontend folder not found: " + $FRONT) }
if (-not (Test-Path $API_FILE)) { Fail ("api.ts not found: " + $API_FILE) }

Write-Section "B) Backup api.ts"
$bakDir = Join-Path $FRONT "backups"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = Join-Path $bakDir ("api.ts.bak_" + $ts)
Copy-Item -Force $API_FILE $bak
Write-Host ("Backup: " + $bak) -ForegroundColor Green

Write-Section "C) Patch api.ts (replace ONLY API_BASE export with strict env requirement)"
$raw = Get-Content -Raw -Encoding UTF8 $API_FILE

# Sanity: don't guess structure if api.ts doesn't have expected helpers
if ($raw -notmatch "readEnvBase") {
  Fail "api.ts does not appear to contain readEnvBase(). Aborting (backup preserved)."
}

# Replace the API_BASE export line (or block) with a strict env requirement.
# This does NOT include any hardcoded URL in source. It only tells user what var to set.
$replacement = @'
const envBase = readEnvBase();

export const API_BASE: string = (() => {
  if (!envBase) {
    throw new Error(
      "Missing VITE_API_BASE_URL. Set it in frontend/.env.local (VITE_API_BASE_URL=YOUR_BACKEND_URL) or your environment."
    );
  }
  return envBase;
})();
'@

# Regex tries to match a single-line API_BASE assignment:
# export const API_BASE: string = ...;
$rx = [regex] 'export\s+const\s+API_BASE\s*:\s*string\s*=\s*[^;]*;'
if ($rx.IsMatch($raw)) {
  $patched = $rx.Replace($raw, $replacement, 1)
} else {
  # If API_BASE isn't single-line, refuse to guess (safer)
  Fail "Could not find a single-line 'export const API_BASE: string = ...;' to replace. Aborting (backup preserved)."
}

# Guard: ensure no hardcoded :8085 or localhost/127 strings exist in api.ts after patch
if ($patched -match "localhost:8085" -or $patched -match "127\.0\.0\.1:8085" -or $patched -match "http://localhost:8085" -or $patched -match "http://127\.0\.0\.1:8085") {
  Fail "api.ts still contains a hardcoded backend URL after patch. Aborting (backup preserved)."
}

# Write as UTF8 (NO BOM) to avoid weird quote/unicode issues
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($API_FILE, $patched, $utf8NoBom)
Write-Host ("Patched: " + $API_FILE) -ForegroundColor Green

Write-Host ""
Write-Host "NOTE: You must set VITE_API_BASE_URL for runtime." -ForegroundColor Yellow
Write-Host "      Put it in frontend\.env.local (recommended) or environment variables." -ForegroundColor Yellow

Write-Section "D) Sanity checks (typecheck + tests) using TEMP env for this window only"
# For sanity checks only (so tests don't fail). This does NOT modify source code.
$env:VITE_API_BASE_URL = "http://127.0.0.1:8085"

Push-Location $FRONT
Write-Host ("In: " + (Get-Location)) -ForegroundColor Gray

Write-Host ""
Write-Host "Typecheck..." -ForegroundColor Cyan
npx tsc -p .\tsconfig.json --noEmit
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "Frontend typecheck failed." }
Write-Host "OK: typecheck passed." -ForegroundColor Green

Write-Host ""
Write-Host "Tests..." -ForegroundColor Cyan
npm test
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "Frontend tests failed." }
Write-Host "OK: tests passed." -ForegroundColor Green

Pop-Location

Write-Section "E) GOLDEN RULE: return to project root"
Set-Location $ROOT
Write-Host ("Returned to: " + (Get-Location)) -ForegroundColor Green
Write-Host "OK: STEP 3A COMPLETE (api.ts requires env; no fallback hardcode in source)." -ForegroundColor Green
