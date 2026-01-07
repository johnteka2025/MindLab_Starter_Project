# PATCH_FIX_API_TS_WARNING_V4.ps1
# Purpose: Fix api.ts fallback warning so it only logs when BOTH env vars are missing.
# Method: Patch only inside function getApiBase(): string { ... } using safe anchors.
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

# 1) Extract getApiBase() body (first occurrence)
$funcPattern = '(?s)(function\s+getApiBase\(\)\s*:\s*string\s*\{)(.*?)(\n\})'
$funcMatch = [regex]::Match($content, $funcPattern)
if (-not $funcMatch.Success) {
  Fail 'Could not locate function getApiBase(): string { ... }. Aborting.'
}

$funcHeader = $funcMatch.Groups[1].Value
$funcBody   = $funcMatch.Groups[2].Value
$funcClose  = $funcMatch.Groups[3].Value

# Guards inside body
if ($funcBody -notmatch 'const\s+fromUrl\s*=\s*readEnvString\("VITE_API_BASE_URL"\)\s*;') {
  Fail 'fromUrl readEnvString("VITE_API_BASE_URL") not found inside getApiBase(). Aborting.'
}
if ($funcBody -notmatch 'const\s+fromAlt\s*=\s*readEnvString\("VITE_API_BASE"\)\s*;') {
  Fail 'fromAlt readEnvString("VITE_API_BASE") not found inside getApiBase(). Aborting.'
}
if ($funcBody -notmatch 'if\s*\(\s*chosen\s*\)\s*return\s+chosen\s*;') {
  Fail 'Anchor "if (chosen) return chosen;" not found inside getApiBase(). Aborting.'
}
if ($funcBody -notmatch 'return\s*"http:\/\/localhost:8085"\s*;') {
  Fail 'Fallback return "http://localhost:8085" not found inside getApiBase(). Aborting.'
}

# 2) Replace fallback section BETWEEN the chosen-return and the fallback return (within getApiBase only)
$innerPattern = '(?s)(if\s*\(\s*chosen\s*\)\s*return\s+chosen\s*;\s*)(.*?)(\s*return\s*"http:\/\/localhost:8085"\s*;)'
$innerMatch = [regex]::Match($funcBody, $innerPattern)
if (-not $innerMatch.Success) {
  Fail 'Could not match fallback section inside getApiBase() body. Aborting.'
}

$prefix = $innerMatch.Groups[1].Value
$suffix = $innerMatch.Groups[3].Value

$replacementMiddle = @'

  // DEV-only fallback so the UI never bricks.
  // Warn only when BOTH env vars are missing.
  if (!fromUrl && !fromAlt) {
    console.warn(
      "[api.ts] Missing VITE_API_BASE_URL / VITE_API_BASE. Falling back to http://localhost:8085 (DEV only)."
    );
  }

'@

$newFuncBody = [regex]::Replace($funcBody, $innerPattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($m)
  return $prefix + $replacementMiddle + $suffix
}, 1)

# 3) Rebuild full file by replacing the original getApiBase function once
$newFunc = $funcHeader + $newFuncBody + $funcClose
$content2 = [regex]::Replace($content, $funcPattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($m)
  return $newFunc
}, 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Patched getApiBase() fallback section (warning now guarded).'
Ok 'Patch completed successfully.'
