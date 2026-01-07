$ErrorActionPreference = "Stop"

$ui = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (!(Test-Path $ui)) { throw "UI file not found: $ui" }

$raw = Get-Content $ui -Raw

# Anchor must be present EXACTLY once (no guessing)
$anchor = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong>'
$anchorMatches = [regex]::Matches($raw, [regex]::Escape($anchor)).Count
if ($anchorMatches -ne 1) {
  throw "ERROR: Expected Progress anchor EXACTLY once, found $anchorMatches. Aborting (no guessing)."
}

# Replace any ugly separator variants near the streak portion
# We normalize to a simple pipe separator: " | Streak: ..."
$before = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong> &nbsp;â€¢&nbsp; Streak: <strong>{streak}</strong>'
$after  = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong> | Streak: <strong>{streak}</strong>'

if ($raw -like "*$before*") {
  $patched = $raw.Replace($before, $after)
}
else {
  # Fallback: handle nbsp without the mis-encoded bullet, still anchored to the Progress line
  $pattern = [regex]::Escape($anchor) + '\s*&nbsp;.*?Streak:\s*<strong>\{streak\}</strong>'
  $matches = [regex]::Matches($raw, $pattern)
  if ($matches.Count -ne 1) {
    throw "ERROR: Could not uniquely match separator block after Progress line. Found $($matches.Count). Aborting (no guessing)."
  }
  $patched = [regex]::Replace(
    $raw,
    $pattern,
    ($anchor + ' | Streak: <strong>{streak}</strong>'),
    1
  )
}

Set-Content -Path $ui -Value $patched -Encoding UTF8
Write-Host "OK: Separator normalized to ' | ' for Progress/Streak."
