# PATCH_FRONTEND_DISPLAY_STREAK_V2.ps1
# Goal: Display "Streak" on DailyChallengeDetailPage using backend /progress streak field.
# Golden Rules: backup first, exact anchors only, abort if not exactly one match, return to project root.

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $root "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (!(Test-Path $target)) {
  throw "ERROR: Target file not found: $target"
}

# Backup
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "${target}.bak_display_streak_v2_${stamp}"
Copy-Item $target $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

# Read
$raw = Get-Content $target -Raw

# ----------------------------
# (A) Ensure ProgressState includes streak (optional field)
# ----------------------------
# We only patch if we can find the ProgressState block at least once.
# This is a tolerant but deterministic patch:
# - If 'type ProgressState' exists and does not already mention 'streak', we insert 'streak?: number;'
# - If it already contains 'streak', we do nothing.

if ($raw -match "type\s+ProgressState\s*=\s*\{") {
  if ($raw -notmatch "streak\s*\??\s*:\s*number") {
    # Insert streak?: number; right after solved line if present, else after total line if present.
    $didInsert = $false

    $patternSolvedLine = "(type\s+ProgressState\s*=\s*\{[\s\S]*?\bsolved\s*:\s*number\s*;)"
    if ([regex]::IsMatch($raw, $patternSolvedLine)) {
      $raw2 = [regex]::Replace(
        $raw,
        $patternSolvedLine,
        '$1' + "`r`n  streak?: number;",
        1,
        [System.Text.RegularExpressions.RegexOptions]::None
      )
      $raw = $raw2
      $didInsert = $true
      Write-Host "OK: Added streak?: number to ProgressState (after solved)." -ForegroundColor Green
    }

    if (-not $didInsert) {
      $patternTotalLine = "(type\s+ProgressState\s*=\s*\{[\s\S]*?\btotal\s*:\s*number\s*;)"
      if ([regex]::IsMatch($raw, $patternTotalLine)) {
        $raw2 = [regex]::Replace(
          $raw,
          $patternTotalLine,
          '$1' + "`r`n  streak?: number;",
          1,
          [System.Text.RegularExpressions.RegexOptions]::None
        )
        $raw = $raw2
        $didInsert = $true
        Write-Host "OK: Added streak?: number to ProgressState (after total)." -ForegroundColor Green
      }
    }

    if (-not $didInsert) {
      throw "ERROR: Found ProgressState, but could not deterministically insert streak field."
    }
  } else {
    Write-Host "OK: ProgressState already has streak field. No change needed." -ForegroundColor Green
  }
} else {
  Write-Host "WARN: Could not find 'type ProgressState = { ... }' block. Skipping type patch." -ForegroundColor Yellow
}

# ----------------------------
# (B) Add streak calculation near solved/total (deterministic anchor)
# ----------------------------
# We look for BOTH lines:
# const total = typeof progress?.total ...
# const solved = typeof progress?.solved ...
# and inject:
# const streak = typeof progress?.streak === "number" ? progress!.streak : 0;
#
# If we can't find those exact patterns, we DO NOT guess.

$calcPattern = @"
const\s+total\s*=\s*typeof\s+progress\?\.\s*total\s*===\s*["']number["']\s*\?\s*progress!\.total\s*:\s*0\s*;
[\r\n]+const\s+solved\s*=\s*typeof\s+progress\?\.\s*solved\s*===\s*["']number["']\s*\?\s*progress!\.solved\s*:\s*0\s*;
"@

$calcMatches = [regex]::Matches($raw, $calcPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($calcMatches.Count -ne 1) {
  throw "ERROR: Could not match the total+solved calc block EXACTLY once. Found $($calcMatches.Count). Aborting (no guessing)."
}

$calcReplacement = @"
const total = typeof progress?.total === "number" ? progress!.total : 0;
const solved = typeof progress?.solved === "number" ? progress!.solved : 0;
const streak = typeof progress?.streak === "number" ? progress!.streak : 0;
"@

$raw = [regex]::Replace($raw, $calcPattern, [regex]::Escape($calcReplacement) -replace "\\r\\n","`r`n", 1, [System.Text.RegularExpressions.RegexOptions]::Multiline)
Write-Host "OK: Added streak calculation near total/solved." -ForegroundColor Green

# ----------------------------
# (C) Update the Progress UI line to show streak (exact anchor)
# ----------------------------
$uiAnchor = "Progress: <strong>{solved}</strong> / <strong>{total}</strong>"
$uiCount = ([regex]::Matches($raw, [regex]::Escape($uiAnchor))).Count
if ($uiCount -ne 1) {
  throw "ERROR: Could not locate the Progress UI anchor EXACTLY once. Found $uiCount. Aborting (no guessing)."
}

$uiReplacement = "Progress: <strong>{solved}</strong> / <strong>{total}</strong>{' '}|{' '}Streak: <strong data-testid=""daily-streak"">{streak}</strong>"
$raw = $raw.Replace($uiAnchor, $uiReplacement)
Write-Host "OK: Updated Progress UI line to include streak." -ForegroundColor Green

# Write back
Set-Content -Path $target -Value $raw -Encoding UTF8
Write-Host "OK: Patch applied successfully." -ForegroundColor Green

# Post-checks (must-pass)
$after = Get-Content $target -Raw
if ($after -notmatch 'data-testid="daily-streak"' -or $after -notmatch 'const\s+streak\s*=') {
  throw "ERROR: Post-check failed: streak UI or streak calc not found after patch."
}
Write-Host "OK: Post-checks passed (streak calc + streak UI present)." -ForegroundColor Green

Set-Location $root
Write-Host "OK: Returned to project root: $root" -ForegroundColor Green
exit 0
