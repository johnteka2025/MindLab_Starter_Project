# PATCH_FRONTEND_DISPLAY_STREAK_SAFE.ps1
# Golden Rules: backup first, exact unique anchors only, abort if ambiguous.

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $root "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (!(Test-Path $target)) { throw "ERROR: Target file not found: $target" }

$stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "${target}.bak_display_streak_safe_${stamp}"
Copy-Item $target $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $target -Raw

# ---- (A) Insert streak calc after the UNIQUE solved line that references progress?.solved ----
# We require EXACTLY ONE match to avoid guessing.
$solvedPattern = '(^\s*const\s+solved\s*=\s*.*progress\?\.\s*solved.*;\s*$)'
$solvedMatches = [regex]::Matches($raw, $solvedPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

if ($solvedMatches.Count -ne 1) {
  throw "ERROR: Could not uniquely locate solved calc line containing progress?.solved. Found $($solvedMatches.Count). Aborting (no guessing)."
}

# If streak line already exists, do not duplicate.
if ($raw -match '^\s*const\s+streak\s*=' ) {
  Write-Host "OK: const streak already exists. Skipping calc insert." -ForegroundColor Yellow
} else {
  $insert = @"
$($solvedMatches[0].Value)
  const streak = typeof progress?.streak === "number" ? progress!.streak : 0;
"@

  # Replace exactly once
  $raw = [regex]::Replace(
    $raw,
    $solvedPattern,
    [System.Text.RegularExpressions.Regex]::Escape($insert).Replace('\r\n',"`r`n"),
    1,
    [System.Text.RegularExpressions.RegexOptions]::Multiline
  )

  Write-Host "OK: Inserted const streak calc after solved line." -ForegroundColor Green
}

# ---- (B) Update Progress UI anchor EXACTLY once ----
$uiAnchor = "Progress: <strong>{solved}</strong> / <strong>{total}</strong>"
$uiCount = ([regex]::Matches($raw, [regex]::Escape($uiAnchor))).Count
if ($uiCount -ne 1) {
  throw "ERROR: Could not locate Progress UI anchor EXACTLY once. Found $uiCount. Aborting (no guessing)."
}

# Avoid duplicate UI insertion
if ($raw -match 'data-testid="daily-streak"' ) {
  Write-Host "OK: Streak UI already present. Skipping UI insert." -ForegroundColor Yellow
} else {
  $uiReplacement = "Progress: <strong>{solved}</strong> / <strong>{total}</strong>{' '}|{' '}Streak: <strong data-testid=""daily-streak"">{streak}</strong>"
  $raw = $raw.Replace($uiAnchor, $uiReplacement)
  Write-Host "OK: Updated Progress UI to include streak." -ForegroundColor Green
}

Set-Content -Path $target -Value $raw -Encoding UTF8
Write-Host "OK: Patch applied successfully." -ForegroundColor Green

# Post-checks
$after = Get-Content $target -Raw
if ($after -notmatch 'const\s+streak\s*=' ) { throw "ERROR: Post-check failed: const streak not found." }
if ($after -notmatch 'data-testid="daily-streak"' ) { throw "ERROR: Post-check failed: streak UI not found." }

Write-Host "OK: Post-checks passed." -ForegroundColor Green
Set-Location $root
Write-Host "OK: Returned to project root: $root" -ForegroundColor Green
exit 0
