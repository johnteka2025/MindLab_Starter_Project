# PATCH_FIX_API_TS_WARNING_V3.ps1
# Purpose: Fix api.ts so the DEV fallback warning is:
# - syntactically correct
# - shown ONLY when BOTH env vars missing
# Approach: Replace the fallback section between:
#   "if (chosen) return chosen;"  and  'return "http://localhost:8085";'
# Golden Rules: backup-first, replace-once, stop-on-mismatch.

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

# Guard: ensure expected anchors exist
if ($content -notmatch 'function\s+getApiBase\(\)\s*:\s*string') {
  Fail 'getApiBase(): string not found. Aborting.'
}
if ($content -notmatch 'if\s*\(\s*chosen\s*\)\s*return\s+chosen\s*;') {
  Fail 'Anchor "if (chosen) return chosen;" not found. Aborting.'
}
if ($content -notmatch 'return\s*"http:\/\/localhost:8085"\s*;') {
  Fail 'Fallback return "http://localhost:8085" not found. Aborting.'
}
if ($content -notmatch 'const\s+fromUrl\s*=\s*readEnvString\("VITE_API_BASE_URL"\)\s*;') {
  Fail 'Expected fromUrl readEnvString("VITE_API_BASE_URL") not found. Aborting.'
}
if ($content -notmatch 'const\s+fromAlt\s*=\s*readEnvString\("VITE_API_BASE"\)\s*;') {
  Fail 'Expected fromAlt readEnvString("VITE_API_BASE") not found. Aborting.'
}

# Replace everything between the chosen-return and the fallback return (first occurrence only)
$pattern = '(?s)(if\s*\(\s*chosen\s*\)\s*return\s+chosen\s*;\s*)(.*?)(\s*return\s*"http:\/\/localhost:8085"\s*;)'

$match = [regex]::Match($content, $pattern)
if (-not $match.Success) {
  Fail 'Could not match fallback section inside getApiBase(). Aborting.'
}

$prefix = $match.Groups[1].Value
$suffix = $match.Groups[3].Value

$replacementMiddle = @'
  
  // DEV-only fallback so the UI never bricks.
  // Warn only when BOTH env vars are missing.
  if (!fromUrl && !fromAlt) {
    console.warn(
      "[api.ts] Missing VITE_API_BASE_URL / VITE_API_BASE. Falling back to http://localhost:8085 (DEV only)."
    );
  }
'@

$newBlock = $prefix + $replacementMiddle + $suffix

$content2 = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($m)
  return $newBlock
}, 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Patched api.ts fallback section (clean warn + guarded).'
Ok 'Patch completed successfully.'
