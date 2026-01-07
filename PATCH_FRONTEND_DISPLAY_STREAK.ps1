$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $projectRoot "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (!(Test-Path $target)) {
  throw "ERROR: File not found: $target"
}

# Backup (Golden Rule)
$backup = "$target.bak_display_streak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $target $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $target -Raw

# --- Patch A: Add streak?: number into ProgressState (exactly once)
$patternA = "(?s)type\s+ProgressState\s*=\s*\{\s*([^}]*?)\};"
$matchA = [regex]::Matches($raw, $patternA)
if ($matchA.Count -ne 1) {
  throw "ERROR: Could not locate ProgressState block EXACTLY once. Found $($matchA.Count). Aborting (no guessing)."
}

$block = $matchA[0].Value
if ($block -notmatch "\bstreak\?\s*:") {
  # Insert streak after solved line if present, else after total line
  if ($block -match "solved:\s*number;\s*") {
    $newBlock = [regex]::Replace($block, "(solved:\s*number;\s*)", "`$1`r`n  streak?: number;`r`n", 1)
  } elseif ($block -match "total:\s*number;\s*") {
    $newBlock = [regex]::Replace($block, "(total:\s*number;\s*)", "`$1`r`n  streak?: number;`r`n", 1)
  } else {
    throw "ERROR: ProgressState block found, but could not find 'total:' or 'solved:' lines to anchor insert. Aborting."
  }
  $raw = $raw.Replace($block, $newBlock)
  Write-Host "OK: Added streak?: number to ProgressState." -ForegroundColor Green
} else {
  Write-Host "OK: ProgressState already has streak. No change needed." -ForegroundColor Green
}

# --- Patch B: Preserve streak when setting progress from POST /progress/solve (exactly once)
$patternB = "(?s)setProgress\(\s*\{\s*total:\s*returned\.total,\s*solved:\s*returned\.solved,\s*solvedIds:\s*returned\.solvedIds\s*\|\|\s*\[\],\s*\}\s*\);"
$matchB = [regex]::Matches($raw, $patternB)
if ($matchB.Count -ne 1) {
  throw "ERROR: Could not locate setProgress({ total: returned.total, solved: returned.solved, solvedIds: ... }) EXACTLY once. Found $($matchB.Count). Aborting (no guessing)."
}

$raw = [regex]::Replace(
  $raw,
  $patternB,
  "setProgress({`r`n          total: returned.total,`r`n          solved: returned.solved,`r`n          streak: typeof returned.streak === `"number`" ? returned.streak : 0,`r`n          solvedIds: returned.solvedIds || [],`r`n        });",
  1
)
Write-Host "OK: Preserved streak when progress comes from POST /progress/solve." -ForegroundColor Green

# --- Patch C: Add streak calculation near total/solved (exactly once)
$patternC = "const\s+total\s*=\s*typeof\s+progress\?\.\s*total\s*===\s*`"number`"\s*\?\s*progress!\.total\s*:\s*0;\s*[\r\n]+const\s+solved\s*=\s*typeof\s+progress\?\.\s*solved\s*===\s*`"number`"\s*\?\s*progress!\.solved\s*:\s*0;"
$matchC = [regex]::Matches($raw, $patternC)
if ($matchC.Count -ne 1) {
  throw "ERROR: Could not locate the total/solved calculation block EXACTLY once. Found $($matchC.Count). Aborting (no guessing)."
}

$replacementC = @"
const total = typeof progress?.total === "number" ? progress!.total : 0;
  const solved = typeof progress?.solved === "number" ? progress!.solved : 0;
  const streak = typeof progress?.streak === "number" ? progress!.streak : 0;
"@

$raw = [regex]::Replace($raw, $patternC, $replacementC, 1)
Write-Host "OK: Added streak constant." -ForegroundColor Green

# --- Patch D: Display streak in the UI next to Progress (exactly once)
$patternD = "Progress:\s*<strong>\{solved\}<\/strong>\s*\/\s*<strong>\{total\}<\/strong>"
$matchD = [regex]::Matches($raw, $patternD)
if ($matchD.Count -ne 1) {
  throw "ERROR: Could not locate the Progress display line EXACTLY once. Found $($matchD.Count). Aborting (no guessing)."
}

$raw = [regex]::Replace(
  $raw,
  $patternD,
  "Progress: <strong>{solved}</strong> / <strong>{total}</strong>{' '}|{' '}Streak: <strong>{streak}</strong>",
  1
)
Write-Host "OK: Updated Progress line to show Streak." -ForegroundColor Green

Set-Content -Path $target -Value $raw -Encoding UTF8
Write-Host "OK: Patch complete: $target" -ForegroundColor Green
Write-Host "NEXT: Run RUN_FULLSTACK_SANITY.ps1, then refresh the browser." -ForegroundColor Cyan
