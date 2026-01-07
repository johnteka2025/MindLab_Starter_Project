# PATCH_STEP7_FrontendFixes.ps1
# Step 7 fixes (FRONTEND ONLY): Daily blank page + Solve dropdown empty
# Golden Rules: backup-first, one change set, stop-on-error, no guessing

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\Projects\MindLab_Starter_Project"

function Fail([string]$msg) {
  Write-Host "ERROR: $msg" -ForegroundColor Red
  exit 1
}
function Ok([string]$msg) {
  Write-Host "OK: $msg" -ForegroundColor Green
}

if (-not (Test-Path $PROJECT_ROOT)) { Fail "Project root not found: $PROJECT_ROOT" }

$dailyFile = Join-Path $PROJECT_ROOT "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
$solveFile = Join-Path $PROJECT_ROOT "frontend\src\pages\SolvePuzzle.tsx"

if (-not (Test-Path $dailyFile)) { Fail "Missing file: $dailyFile" }
if (-not (Test-Path $solveFile)) { Fail "Missing file: $solveFile" }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item $dailyFile "$dailyFile.bak_$ts" -Force
Copy-Item $solveFile "$solveFile.bak_$ts" -Force
Ok "Backups created:"
Ok " - $dailyFile.bak_$ts"
Ok " - $solveFile.bak_$ts"

# ----------------------------
# Fix 1: Daily blank page (Link import)
# ----------------------------
$daily = Get-Content $dailyFile -Raw
$hasLinkUsage  = ($daily -match '<\s*Link\b')
$hasLinkImport = ($daily -match 'import\s*\{\s*[^}]*\bLink\b[^}]*\}\s*from\s*["'']react-router-dom["''];')

if ($hasLinkUsage -and -not $hasLinkImport) {
  if ($daily -match 'import\s*\{\s*([^}]*)\}\s*from\s*["'']react-router-dom["''];') {
    $daily2 = [regex]::Replace(
      $daily,
      'import\s*\{\s*([^}]*)\}\s*from\s*["'']react-router-dom["''];',
      {
        param($m)
        $inside = $m.Groups[1].Value.Trim()
        if ($inside -match '(^|,)\s*Link\s*(,|$)') { return $m.Value }
        if ($inside.Length -eq 0) { return 'import { Link } from "react-router-dom";' }
        return "import { $inside, Link } from `"react-router-dom`";"
      },
      1
    )
    Set-Content $dailyFile $daily2 -Encoding UTF8
    Ok "DailyChallengeDetailPage.tsx: inserted Link into existing react-router-dom import."
  }
  else {
    $lines = Get-Content $dailyFile
    if ($lines.Count -lt 1) { Fail "DailyChallengeDetailPage.tsx is empty; abort." }

    $insertAt = -1
    for ($i=0; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -match '^\s*import\s+') { $insertAt = $i + 1; break }
    }
    if ($insertAt -lt 0) { Fail "No import statements found to anchor Link import; abort." }

    $out = New-Object System.Collections.Generic.List[string]
    for ($i=0; $i -lt $lines.Count; $i++) {
      $out.Add($lines[$i])
      if ($i -eq ($insertAt - 1)) { $out.Add('import { Link } from "react-router-dom";') }
    }

    Set-Content $dailyFile ($out -join "`r`n") -Encoding UTF8
    Ok "DailyChallengeDetailPage.tsx: added new Link import."
  }
}
elseif ($hasLinkUsage -and $hasLinkImport) {
  Ok "DailyChallengeDetailPage.tsx: Link usage + import already present (no change)."
}
else {
  Ok "DailyChallengeDetailPage.tsx: no <Link> usage detected (no Link import change)."
}

# ----------------------------
# Fix 2: Solve dropdown empty (puzzles response shape)
# ----------------------------
$solve = Get-Content $solveFile -Raw

if ($solve -notmatch '\/puzzles') {
  Fail "SolvePuzzle.tsx does not contain '/puzzles' call. Aborting to prevent wrong-file edit."
}

# Find: const <var> = await ... "/puzzles" ... ;
$assignPattern = '(const\s+(?<var>\w+)\s*=\s*await\s+[^;]*["'']\/puzzles["''][^;]*;)'
$match = [regex]::Match($solve, $assignPattern)
if (-not $match.Success) {
  Fail "Could not find a 'const X = await ... \"/puzzles\" ...;' assignment to patch safely."
}

$varName = $match.Groups["var"].Value
if ([string]::IsNullOrWhiteSpace($varName)) {
  Fail "Failed to capture variable name for puzzles response."
}

# IMPORTANT: use ${varName} so PowerShell doesn't treat $varName? as a variable
$assignmentLine = $match.Value

$insertion = @"
$assignmentLine
const list = Array.isArray($varName)
  ? $varName
  : Array.isArray(${varName}?.puzzles)
    ? $varName.puzzles
    : [];
setPuzzles(list);
"@

$solve2 = [regex]::Replace($solve, $assignPattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($m)
  return $insertion
}, 1)

# Remove ONE subsequent setPuzzles(...) that is not setPuzzles(list);
$solve3 = [regex]::Replace($solve2, '(?s)setPuzzles\((?!list\)).*?\);\s*', '', 1)

Set-Content $solveFile $solve3 -Encoding UTF8
Ok "SolvePuzzle.tsx: normalized puzzles response to array + removed one duplicate setPuzzles(...) call."

Ok "Patch completed successfully."
