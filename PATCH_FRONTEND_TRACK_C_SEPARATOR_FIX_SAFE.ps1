# PATCH_FRONTEND_TRACK_C_SEPARATOR_FIX_SAFE.ps1
# Fixes the "â€¢" separator artifact and (optionally) dedupes duplicated Progress/Refresh <p> blocks.
# Golden Rules:
# - Backup first
# - Exact matching / count checks
# - Write UTF-8
# - Abort on ambiguity

$ErrorActionPreference = "Stop"

$ui = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (-not (Test-Path $ui)) { throw "UI file not found: $ui" }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$ui.bak_trackC_sepfix_$ts"
Copy-Item $ui $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

# Read raw
$raw = Get-Content -Path $ui -Raw -Encoding UTF8

# 1) Fix bad separator encoding:
# Replace JSX separator like: {" â€¢ "} (with variable spaces) -> {" • "}
$sepPattern = '\{\s*"\s*â€¢\s*"\s*\}'
$sepMatches = [regex]::Matches($raw, $sepPattern)
if ($sepMatches.Count -lt 1) {
  Write-Host "WARN: No JSX â€¢ separator found via regex. Continuing to check for literal '&nbsp;â€¢&nbsp;'..." -ForegroundColor Yellow
} else {
  $raw = [regex]::Replace($raw, $sepPattern, '{ " • " }')
  Write-Host "OK: Replaced JSX â€¢ separators: $($sepMatches.Count)" -ForegroundColor Green
}

# Also fix any literal HTML entity sequences if present (rare, but safe)
if ($raw -match '&nbsp;â€¢&nbsp;') {
  $raw = $raw -replace '&nbsp;â€¢&nbsp;', ' • '
  Write-Host "OK: Replaced literal '&nbsp;â€¢&nbsp;' sequences." -ForegroundColor Green
}

# 2) Optional: de-dupe duplicated Progress/Refresh <p> block if it appears more than once
# We match the WHOLE <p> that contains:
#   Progress: <strong>{solved}</strong> / <strong>{total}</strong>
# and the Refresh Progress button.
$progressBlockPattern = '(?s)<p\s+style=\{\{\s*marginTop:\s*0\s*\}\}\>\s*.*?Progress:\s*<strong>\{solved\}<\/strong>\s*\/\s*<strong>\{total\}<\/strong>.*?Refresh\s+Progress.*?<\/button>\s*<\/p>'
$blocks = [regex]::Matches($raw, $progressBlockPattern)

if ($blocks.Count -gt 1) {
  Write-Host "WARN: Found $($blocks.Count) Progress/Refresh <p> blocks. Removing duplicates (keeping the first)." -ForegroundColor Yellow

  # Remove from the end to preserve indices
  for ($i = $blocks.Count - 1; $i -ge 1; $i--) {
    $m = $blocks[$i]
    $raw = $raw.Remove($m.Index, $m.Length)
  }

  Write-Host "OK: De-dupe complete. Kept 1 Progress/Refresh block." -ForegroundColor Green
} else {
  Write-Host "OK: Progress/Refresh <p> block count is $($blocks.Count). No de-dupe needed." -ForegroundColor Green
}

# Write back UTF-8
Set-Content -Path $ui -Value $raw -Encoding UTF8
Write-Host "OK: Patch applied to: $ui" -ForegroundColor Green
Write-Host "OK: If anything looks wrong, restore: $backup" -ForegroundColor Green
