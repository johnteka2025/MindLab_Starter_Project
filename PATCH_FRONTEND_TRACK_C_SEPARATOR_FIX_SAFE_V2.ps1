# PATCH_FRONTEND_TRACK_C_SEPARATOR_FIX_SAFE_V2.ps1
# Fix bad separator characters in DailyChallengeDetailPage.tsx (no backend touch).
# Golden Rules: backup first, match EXACTLY once, abort if ambiguous.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ui = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (-not (Test-Path -LiteralPath $ui)) { throw "UI file not found: $ui" }

$raw = Get-Content -LiteralPath $ui -Raw

# 1) Ensure the Progress/Streak UI line exists exactly once (anchor)
$anchor = "Progress: <strong>{solved}</strong> / <strong>{total}</strong>"
$anchorMatches = [regex]::Matches($raw, [regex]::Escape($anchor)).Count
if ($anchorMatches -ne 1) {
  throw "ERROR: Anchor line not found EXACTLY once. Found $anchorMatches. Aborting (no guessing)."
}

# 2) Ensure we actually have the bad separator or a known variant somewhere near the Progress/Streak line
# We'll patch by regex-replacing the entire Progress...Streak line (exactly once)
$pattern = @'
Progress:\s*<strong>\{solved\}</strong>\s*/\s*<strong>\{total\}</strong>.*?Streak:\s*<strong>\{streak\}</strong>
'@

$re = New-Object System.Text.RegularExpressions.Regex(
  $pattern,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

$lineMatches = $re.Matches($raw).Count
if ($lineMatches -ne 1) {
  throw "ERROR: Could not match Progress/Streak display line EXACTLY once. Found $lineMatches. Aborting (no guessing)."
}

# Backup (Golden Rule)
$backup = "$ui.bak_sepfix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $ui -Destination $backup -Force
Write-Host "OK: Backup created: $backup"

# Replacement: clean, no HTML entities, no mojibake
$replacement = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong> {" | "} Streak: <strong>{streak}</strong>'

$patched = $re.Replace($raw, $replacement, 1)

# Sanity: confirm the bad token is gone and replacement exists
if ($patched -match "â€") {
  throw "ERROR: Patch did not remove bad token 'â€'. Aborting (no guessing). Restore: $backup"
}
if (-not ($patched -like "*{`" | `"}*")) {
  throw "ERROR: Replacement did not apply as expected. Aborting (no guessing). Restore: $backup"
}

Set-Content -LiteralPath $ui -Value $patched -Encoding UTF8
Write-Host "OK: Separator fixed in: $ui"
Write-Host "OK: If anything looks wrong, restore backup:"
Write-Host "    Copy-Item `"$backup`" `"$ui`" -Force"
exit 0
