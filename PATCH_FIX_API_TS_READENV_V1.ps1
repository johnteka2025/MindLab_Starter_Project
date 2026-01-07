# PATCH_FIX_API_TS_READENV_V1.ps1
# Purpose: Make readEnvString use import.meta.env directly (Vite-correct),
#          so getApiBase sees VITE_API_BASE_URL / VITE_API_BASE properly.
# Golden Rules: backup-first, patch-once, stop-on-mismatch.

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

# Guard: ensure helper exists
if ($content -notmatch 'function\s+readEnvString\s*\(') {
  Fail 'readEnvString() not found in api.ts. Aborting.'
}

# Replace only the specific line that reads env dynamically.
# Old form (seen in your snippet):
# const v = (import.meta as any)?.env?.[key];
$pattern = 'const\s+v\s*=\s*\(import\.meta\s+as\s+any\)\?\.\s*env\?\.\s*\[key\]\s*;'
if ($content -notmatch $pattern) {
  Fail 'Could not find the dynamic env read line in readEnvString. Aborting (no guessing).'
}

# New, Vite-correct dynamic access:
# const v = (import.meta.env as any)?.[key];
$content2 = [regex]::Replace($content, $pattern, 'const v = (import.meta.env as any)?.[key];', 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Patched readEnvString() to use import.meta.env directly.'
Ok 'Patch completed successfully.'
