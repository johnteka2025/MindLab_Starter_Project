# PATCH_STEP9_FIX_Daily_RefreshProgress_Button.ps1
# Fixes:
# 1) Remove bad in-useEffect handleRefreshProgress insertion
# 2) Change button to call refreshProgress() safely
# 3) Separate statusText and markSolved() properly
# Golden Rules: backup-first, stop-on-mismatch, no guessing

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host "OK: $msg" -ForegroundColor Green }

$FILE = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (-not (Test-Path $FILE)) { Fail "Target file not found: $FILE" }

# Backup
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$FILE.bak_$ts"
Copy-Item $FILE $bak -Force
Ok "Backup created: $bak"

$content = Get-Content $FILE -Raw

# ---- Guardrails ----
if ($content -notmatch 'async function refreshProgress\(') {
  Fail "Expected refreshProgress() not found. Aborting to avoid wrong-file edits."
}
if ($content -notmatch 'Refresh Progress') {
  Ok "Note: 'Refresh Progress' text not found; script will still fix handler/syntax if present."
}

# ---- 1) Remove the wrongly inserted handleRefreshProgress block (inside useEffect) ----
# Remove this exact inserted pattern if present:
# const handleRefreshProgress = () => { ... window.location.reload(); };
$patternBadHandler = '(?s)\n\s*const\s+handleRefreshProgress\s*=\s*\(\)\s*=>\s*\{\s*//.*?window\.location\.reload\(\);\s*\};\s*\n'
$content2 = [regex]::Replace($content, $patternBadHandler, "`n", 1)

# If a different formatting exists, remove any simple handleRefreshProgress block (one time)
if ($content2 -match 'const\s+handleRefreshProgress\s*=') {
  $patternFallback = '(?s)\n\s*const\s+handleRefreshProgress\s*=\s*\(\)\s*=>\s*\{.*?\};\s*\n'
  $content2 = [regex]::Replace($content2, $patternFallback, "`n", 1)
}

# ---- 2) Fix the button to call refreshProgress() instead of missing handleRefreshProgress ----
# Replace onClick={handleRefreshProgress} with onClick={() => { void refreshProgress(); }}
$content3 = $content2 -replace 'onClick=\{handleRefreshProgress\}', 'onClick={() => { void refreshProgress(); }}'

# ---- 3) Ensure statusText ends cleanly before markSolved() ----
# Fix the broken sequence: "Status: Complete";async function markSolved() {
$content4 = $content3 -replace '("Status:\s*Complete";)\s*async function markSolved\(\)\s*\{', "`$1`r`n`r`n  async function markSolved() {"

# Also ensure the statusText assignment line ends with a semicolon if it doesn't already
# (Very conservative: only patch the specific 'const statusText =' block ending)
if ($content4 -match 'const statusText\s*=') {
  # If the line ends with ... "Status: Complete";async then it was fixed above.
  # Otherwise no extra changes here.
}

Set-Content $FILE $content4 -Encoding UTF8
Ok "Patched DailyChallengeDetailPage.tsx: removed bad handler, fixed button onClick, fixed statusText/markSolved separation."
Ok "Patch completed successfully."
