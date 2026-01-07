# PATCH_FIX_API_TS_WARNING_AND_FALLBACK.ps1
# Purpose:
# 1) Fix malformed console.warn block in frontend\src\api.ts
# 2) Ensure warning logs ONLY when BOTH VITE_API_BASE_URL and VITE_API_BASE are missing
# 3) Keep fallback return http://localhost:8085 unchanged
# Golden Rules: backup-first, patch-once, stop-on-mismatch

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$msg) { Write-Host ('ERROR: ' + $msg) -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host ('OK: ' + $msg) -ForegroundColor Green }

$FILE = 'C:\Projects\MindLab_Starter_Project\frontend\src\api.ts'
if (-not (Test-Path $FILE)) { Fail ('Target file not found: ' + $FILE) }

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$bak = $FILE + '.bak_' + $ts
Copy-Item $FILE $bak -Force
Ok ('Backup created: ' + $bak)

$content = Get-Content $FILE -Raw

# Guard: make sure we're patching the intended area
if ($content -notmatch 'function getApiBase\(\)\s*:\s*string') {
  Fail 'getApiBase() not found in api.ts. Aborting.'
}
if ($content -notmatch 'Missing VITE_API_BASE_URL\s*/\s*VITE_API_BASE') {
  Fail 'Expected warning text not found in api.ts. Aborting.'
}
if ($content -notmatch 'return\s+"http:\/\/localhost:8085";') {
  Fail 'Expected fallback return "http://localhost:8085" not found. Aborting.'
}

# Replace the broken warn/string/fallback region with a correct guarded warning + same fallback return.
# We match the specific broken sequence shown in your output:
# console.warn( \n ); \n " [api.ts] Missing ..."; \n return "http://localhost:8085";
$pattern = '(?s)console\.warn\s*\(\s*\)\s*;\s*"\[api\.ts\]\s*Missing VITE_API_BASE_URL\s*\/\s*VITE_API_BASE\.\s*Falling back to http:\/\/localhost:8085\s*\(DEV only\)\."\s*;\s*return\s*"http:\/\/localhost:8085";'

if ($content -notmatch $pattern) {
  Fail 'Could not match the broken warning+fallback block exactly. Aborting (no guessing).'
}

$replacement = @'
if (!fromUrl && !fromAlt) {
  console.warn(
    "[api.ts] Missing VITE_API_BASE_URL / VITE_API_BASE. Falling back to http://localhost:8085 (DEV only)."
  );
}
return "http://localhost:8085";
'@

$content2 = [regex]::Replace($content, $pattern, $replacement, 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Patched api.ts: fixed malformed warn and guarded it (only warns when both vars missing).'
Ok 'Patch completed successfully.'
