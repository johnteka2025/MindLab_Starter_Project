# PATCH_FRONTEND_UX_POLISH_TRACK_C.ps1
# Frontend-only UX polish:
# 1) Improve streak display (🔥 when > 0)
# 2) Disable Solve button when puzzle already solved
# 3) Keep changes confined to DailyChallengeDetailPage.tsx
# Golden Rules: backup, exact anchors, abort on ambiguity

$ErrorActionPreference = "Stop"

$ui = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (!(Test-Path $ui)) { throw "File not found: $ui" }

# Backup
$backup = "$ui.bak_trackC_ux_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ui $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $ui -Raw

# ---- 1) Ensure we have a safe derived variable for streak + solved flags ----
# Anchor: find the line that defines `const solved = ... progress?.solved ...`
# We'll insert derived values AFTER that block, once, to avoid guessing.

$anchorSolvedPattern = [regex]::Escape('const solved = typeof progress?.solved === "number" ? progress!.solved : 0;')
$matchesSolved = [regex]::Matches($raw, $anchorSolvedPattern)
if ($matchesSolved.Count -ne 1) {
  throw "ERROR: Could not locate solved-derivation line EXACTLY once. Found $($matchesSolved.Count). Aborting (no guessing)."
}

$insertAfterSolved = @'
const solved = typeof progress?.solved === "number" ? progress!.solved : 0;
const streak = typeof (progress as any)?.streak === "number" ? (progress as any).streak : 0;

// solvedIds comes from backend GET /progress (derived), but some flows may not include it.
// We'll defensively treat missing as empty list.
const solvedIds: string[] = Array.isArray((progress as any)?.solvedIds) ? (progress as any).solvedIds : [];

// Determine if currently selected puzzle is solved
const selectedPuzzleId = selectedPuzzle?.id != null ? String(selectedPuzzle.id) : null;
const isSelectedSolved = selectedPuzzleId ? solvedIds.includes(selectedPuzzleId) : false;
'@

# Replace ONLY the first occurrence of the solved line with the expanded block.
$raw2 = [regex]::Replace($raw, $anchorSolvedPattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($m) $insertAfterSolved
}, 1)

# ---- 2) Patch Progress UI line to add conditional flame for streak ----
# Anchor must match the exact line you previously verified exists:
# Progress: <strong>{solved}</strong> / <strong>{total}</strong> ... Streak: <strong>{streak}</strong>
# We will replace that exact segment with a more readable one:
# Progress ...  |  🔥 Streak: X (if >0 else Streak: X)

$progressLinePattern = [regex]::Escape('Progress: <strong>{solved}</strong> / <strong>{total}</strong>') +
  '([\s\S]{0,120}?)' +
  [regex]::Escape('Streak: <strong>{streak}</strong>')

$matchesProgress = [regex]::Matches($raw2, $progressLinePattern)
if ($matchesProgress.Count -ne 1) {
  throw "ERROR: Could not match the Progress/Streak UI block EXACTLY once. Found $($matchesProgress.Count). Aborting (no guessing)."
}

$progressReplacement = 'Progress: <strong>{solved}</strong> / <strong>{total}</strong>&nbsp;&nbsp;|&nbsp;&nbsp;{streak > 0 ? (<><span role="img" aria-label="streak">🔥</span>&nbsp;Streak: <strong>{streak}</strong></>) : (<>Streak: <strong>{streak}</strong></>)}'

$raw3 = [regex]::Replace($raw2, $progressLinePattern, $progressReplacement, 1)

# ---- 3) Disable Solve button if selected is already solved ----
# We look for the button that triggers solve. We'll anchor on `setSolveOk(` usage line nearby:
# In your file there is a "Solved" action UI. We'll patch a common pattern:
# <button ... disabled={...} ...>Solved</button>
# If we cannot match EXACTLY once, we abort.

# We attempt two safe anchors:
# (a) a <button ...>Solved</button> block
# (b) a <button type="button" ...>Solved</button> block
# We'll patch the first exact match we can find, but ONLY if the chosen pattern matches exactly once.

$buttonPatternA = '<button([^>]*?)>\s*Solved\s*</button>'
$buttonMatchesA = [regex]::Matches($raw3, $buttonPatternA, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

$buttonPatternB = '<button\s+type="button"([^>]*?)>\s*Solved\s*</button>'
$buttonMatchesB = [regex]::Matches($raw3, $buttonPatternB, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

$chosenPattern = $null
$chosenCount = 0

if ($buttonMatchesB.Count -eq 1) {
  $chosenPattern = $buttonPatternB
  $chosenCount = 1
} elseif ($buttonMatchesA.Count -eq 1) {
  $chosenPattern = $buttonPatternA
  $chosenCount = 1
} else {
  throw "ERROR: Could not uniquely identify the Solve button block to disable. PatternA found $($buttonMatchesA.Count), PatternB found $($buttonMatchesB.Count). Aborting (no guessing)."
}

# Add disabled + title + style hint when solved.
# If there's already a disabled=, we abort to avoid double attributes.
if ($raw3 -match 'disabled\s*=\s*{') {
  throw "ERROR: A disabled={...} attribute already exists on a button somewhere; patch would be ambiguous. Aborting (no guessing)."
}

$buttonReplacement = '<button$1 disabled={isSelectedSolved} title={isSelectedSolved ? "Already solved" : ""} style={isSelectedSolved ? { opacity: 0.6, cursor: "not-allowed" } : undefined}>Solved</button>'

$raw4 = [regex]::Replace($raw3, $chosenPattern, $buttonReplacement, 1, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

# Write back
Set-Content -Path $ui -Value $raw4 -Encoding UTF8
Write-Host "OK: Track C UX polish patch applied to $ui" -ForegroundColor Green
Write-Host "OK: If anything looks wrong, restore backup: $backup" -ForegroundColor Yellow
