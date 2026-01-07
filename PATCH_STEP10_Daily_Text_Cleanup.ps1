# PATCH_STEP10_Daily_Text_Cleanup.ps1
# Purpose: Replace outdated Daily UI instruction text with a Refresh Progress tip.
# Golden Rules: backup-first, stop-on-mismatch, no guessing.

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

$old = 'Next: open Progress to see updated totals.'
$new = 'Tip: Click Refresh Progress to update totals.'

if ($content -notmatch [regex]::Escape($old)) {
  Fail ('Did not find the exact text to replace: ' + $old)
}

$content2 = $content -replace [regex]::Escape($old), $new

Set-Content $FILE $content2 -Encoding UTF8
Ok 'Replaced Daily UI instruction text.'
Ok 'Patch completed successfully.'
