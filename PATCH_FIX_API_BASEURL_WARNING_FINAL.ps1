# PATCH_FIX_API_BASEURL_WARNING_FINAL.ps1
# Purpose: Make api.ts warn ONLY when BOTH env vars are missing.
# Golden Rules: backup-first, minimal change, deterministic.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$msg) { Write-Host ('ERROR: ' + $msg) -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host ('OK: ' + $msg) -ForegroundColor Green }

$FILE = 'C:\Projects\MindLab_Starter_Project\frontend\src\api.ts'
if (-not (Test-Path $FILE)) { Fail ('Target file not found: ' + $FILE) }

# Backup
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$bak = $FILE + '.bak_' + $ts
Copy-Item $FILE $bak -Force
Ok ('Backup created: ' + $bak)

$content = Get-Content $FILE -Raw

# Guard: ensure expected warning exists
if ($content -notmatch 'Missing VITE_API_BASE_URL\s*/\s*VITE_API_BASE') {
  Fail 'Expected warning text not found in api.ts. Aborting to avoid wrong patch.'
}

# Replace unconditional warning with guarded version
$old = @'
console.warn(
  "[api.ts] Missing VITE_API_BASE_URL / VITE_API_BASE. Falling back to http://localhost:8085 (DEV only)."
);
return "http://localhost:8085";
'@

$new = @'
if (!import.meta.env.VITE_API_BASE_URL && !import.meta.env.VITE_API_BASE) {
  console.warn(
    "[api.ts] Missing VITE_API_BASE_URL / VITE_API_BASE. Falling back to http://localhost:8085 (DEV only)."
  );
}
return "http://localhost:8085";
'@

if ($content -notmatch [regex]::Escape($old.Trim())) {
  Fail 'Exact fallback block not found. Aborting (no guessing).'
}

$content2 = $content -replace [regex]::Escape($old.Trim()), $new.Trim()

Set-Content $FILE $content2 -Encoding UTF8
Ok 'api.ts warning is now correctly guarded.'
Ok 'Patch completed successfully.'
