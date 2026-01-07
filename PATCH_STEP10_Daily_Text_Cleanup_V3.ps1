# PATCH_STEP10_Daily_Text_Cleanup_V3.ps1
# Purpose: Replace JSX "Next: open <Link ...>Progress</Link> to see updated totals."
#          with "Tip: Click Refresh Progress to update totals."
# Golden Rules: backup-first, replace-once, stop-on-mismatch.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$msg) { Write-Host ('ERROR: ' + $msg) -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host ('OK: ' + $msg) -ForegroundColor Green }

$FILE = 'C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx'
if (-not (Test-Path $FILE)) { Fail ('Target file not found: ' + $FILE) }

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$bak = $FILE + '.bak_' + $ts
Copy-Item $FILE $bak -Force
Ok ('Backup created: ' + $bak)

$content = Get-Content $FILE -Raw

# Match the specific JSX pattern (tolerant of whitespace):
# Next: open <Link to="/app/progress">Progress</Link> to see updated totals.
$pattern = '(?s)Next:\s*open\s*<Link\s+to\s*=\s*["'']/app/progress["'']\s*>\s*Progress\s*</Link>\s*to\s*see\s*updated\s*totals\.'

if ($content -notmatch $pattern) {
  Fail 'Could not find the JSX Next/Progress link hint to replace (pattern not found).'
}

$replacement = 'Tip: Click Refresh Progress to update totals.'

$content2 = [regex]::Replace($content, $pattern, $replacement, 1)

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Replaced Next/Progress JSX hint with Refresh tip.'
Ok 'Patch completed successfully.'
