# PATCH_FRONTEND_DISPLAY_STREAK_V3_SAFE.ps1
# Goal: Display streak in DailyChallengeDetailPage.tsx (single-file change)
# Golden Rules: backup, exact anchors, no guessing.

$ErrorActionPreference = "Stop"

$project = "C:\Projects\MindLab_Starter_Project"
$ui = Join-Path $project "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (-not (Test-Path $ui)) { throw "UI file not found: $ui" }

# Backup (Golden Rule)
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$ui.bak_display_streak_v3_$stamp"
Copy-Item $ui $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $ui -Raw

# ---------
# 1) Ensure we have a streak variable (derived from progress)
# Anchor on your real existing line: const solved = typeof progress?.solved ...
# Insert streak line immediately after it, only if not already present.
# ---------

if ($raw -notmatch 'const\s+streak\s*=') {
  $patternSolvedLine = 'const\s+solved\s*=\s*typeof\s+progress\?\.(solved)\s*===\s*"number"\s*\?\s*progress!\.(solved)\s*:\s*0\s*;'
  $m = [regex]::Matches($raw, $patternSolvedLine, [System.Text.RegularExpressions.RegexOptions]::Multiline)

  if ($m.Count -ne 1) {
    throw "ERROR: Could not match the solved calculation line EXACTLY once. Found $($m.Count). Aborting (no guessing). Backup: $backup"
  }

  $replacementSolved = $m[0].Value + "`r`n" + 'const streak = typeof progress?.streak === "number" ? progress!.streak : 0;'
  $raw = [regex]::Replace(
    $raw,
    $patternSolvedLine,
    [System.Text.RegularExpressions.MatchEvaluator]{ param($mm) $replacementSolved },
    [System.Text.RegularExpressions.RegexOptions]::Multiline
  )

  Write-Host "OK: Added 'const streak = ...' derived from progress." -ForegroundColor Green
}
else {
  Write-Host "OK: streak variable already exists. No change needed." -ForegroundColor Green
}

# ---------
# 2) Update Progress UI line to display streak
# Your exact line exists (you proved it):
# Progress: <strong>{solved}</strong> / <strong>{total}</strong>
# We will append:  • Streak: <strong>{streak}</strong>
# ---------

$progressLine = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong>'
$matches2 = [regex]::Matches($raw, [regex]::Escape($progressLine))

if ($matches2.Count -ne 1) {
  throw "ERROR: Could not locate the Progress UI line EXACTLY once. Found $($matches2.Count). Aborting (no guessing). Backup: $backup"
}

$newProgressLine = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong> &nbsp;•&nbsp; Streak: <strong>{streak}</strong>'
$raw = $raw.Replace($progressLine, $newProgressLine)

Write-Host "OK: Updated Progress UI line to include streak." -ForegroundColor Green

# Write file
Set-Content -Path $ui -Value $raw -Encoding UTF8
Write-Host "OK: Patch complete: $ui" -ForegroundColor Green
Write-Host "OK: If anything looks wrong, restore backup: $backup" -ForegroundColor Yellow
