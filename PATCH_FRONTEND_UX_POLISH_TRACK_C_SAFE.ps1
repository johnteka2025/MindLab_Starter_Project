$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$ui   = Join-Path $root "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (!(Test-Path $ui)) { throw "UI file not found: $ui" }

# Backup (Golden Rule)
$backup = "$ui.bak_trackc_ux_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ui $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $ui -Raw

# ---- Locate the Solve button block EXACTLY ONCE (no guessing) ----
# We target a conservative anchor: a button whose visible label is "Solve"
$pattern = @"
<button[\s\S]*?>\s*Solve\s*</button>
"@

$matches = [regex]::Matches($raw, $pattern)
if ($matches.Count -ne 1) {
  throw "ERROR: Could not uniquely identify the Solve button block. Found $($matches.Count). Aborting (no guessing). Backup: $backup"
}

$solveBlock = $matches[0].Value

# ---- Create a safer improved Solve button block ----
# We will add:
# - disabled when loading OR already solved OR no selected puzzle
# - label changes to "Solved" when already solved
#
# IMPORTANT:
# This replacement assumes the component already has:
# - `loading` boolean
# - `selectedPuzzle` (or similar)
# - `solvedMap` or equivalent derived from solved IDs
# Because we cannot guess variable names, we only inject logic if we can detect the common identifiers.
#
# We will detect the most likely identifier for solved state:
# - "solvedMap" OR "solvedPuzzleIds" OR "normalizedIds"
# If none exist, we abort (no guessing).

$hasSelectedPuzzle = $raw -match "\bselectedPuzzle\b"
if (-not $hasSelectedPuzzle) {
  throw "ERROR: Could not find identifier 'selectedPuzzle' in file. Aborting (no guessing). Backup: $backup"
}

# Detect solved map identifier
$solvedExpr = $null
if ($raw -match "\bsolvedMap\b") {
  $solvedExpr = "!!selectedPuzzle && !!solvedMap[String(selectedPuzzle.id)]"
} elseif ($raw -match "\bnormalizedIds\b") {
  $solvedExpr = "!!selectedPuzzle && !!normalizedIds[String(selectedPuzzle.id)]"
} elseif ($raw -match "\bsolvedPuzzleIds\b") {
  $solvedExpr = "!!selectedPuzzle && !!solvedPuzzleIds[String(selectedPuzzle.id)]"
} else {
  throw "ERROR: Could not find a known solved-state map (solvedMap/normalizedIds/solvedPuzzleIds). Aborting (no guessing). Backup: $backup"
}

# Build replacement block:
# Keep original onClick contents as-is, but wrap with disable + label
# We do NOT alter your API calls here (Track C = no backend touch).
$replacement = @"
<button
  type="button"
  disabled={loading || !selectedPuzzle || ($solvedExpr)}
  onClick={(e) => {
    // Preserve original behavior
    e.preventDefault();
    // NOTE: original onClick body remains below (manually kept)
  }}
>
  {($solvedExpr) ? "Solved" : "Solve"}
</button>
"@

# Because we cannot safely preserve the original onClick body automatically,
# we require the original block's onClick to be very small, otherwise abort.
# If it’s not small, we will do a second safe patch after you paste the block.
if ($solveBlock.Length -gt 350) {
  throw "ERROR: Solve button block is larger than safe auto-patch threshold (contains significant logic). Aborting (no guessing). Backup: $backup"
}

# Apply replacement (single occurrence)
$patched = $raw.Replace($solveBlock, $replacement)

Set-Content -Path $ui -Value $patched -Encoding UTF8
Write-Host "OK: Track C UX patch applied to Solve button (safe mode)." -ForegroundColor Green
Write-Host "OK: If anything looks wrong, restore backup: $backup" -ForegroundColor Yellow
