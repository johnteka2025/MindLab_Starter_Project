$ErrorActionPreference = "Stop"

$ui = "C:\Projects\MindLab_Starter_Project\frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
if (!(Test-Path $ui)) { throw "UI file not found: $ui" }

# Backup (Golden Rule)
$backup = "$ui.bak_trackC_ux_v2_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ui $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$raw = Get-Content $ui -Raw

# ------------------------------------------------------------
# Patch A: Fix the Progress/Streak separator encoding
# Replace whatever is between total and Streak ON THAT LINE
# with JSX {" • "}
# ------------------------------------------------------------
$progressPattern = '(Progress:\s*<strong>\{solved\}<\/strong>\s*\/\s*<strong>\{total\}<\/strong>)[^\r\n]*(Streak:\s*<strong>\{streak\}<\/strong>)'
$progressMatches = [regex]::Matches($raw, $progressPattern)
if ($progressMatches.Count -ne 1) {
  throw "ERROR: Could not uniquely match Progress/Streak line. Found $($progressMatches.Count). Aborting (no guessing). Backup: $backup"
}

$raw = [regex]::Replace($raw, $progressPattern, '$1 {" • "} $2', 1)

Write-Host "OK: Progress/Streak separator normalized." -ForegroundColor Green

# ------------------------------------------------------------
# Patch B: Improve Solve button label (stable anchor: data-testid)
# Must match exactly once
# ------------------------------------------------------------
$buttonPattern = '(?s)<button\s+data-testid="daily-mark-solved"[\s\S]*?>[\s\S]*?<\/button>'
$buttonMatches = [regex]::Matches($raw, $buttonPattern)
if ($buttonMatches.Count -ne 1) {
  throw "ERROR: Could not uniquely match Solve button block. Found $($buttonMatches.Count). Aborting (no guessing). Backup: $backup"
}

$buttonReplacement = @'
<button
  data-testid="daily-mark-solved"
  onClick={markSolved}
  disabled={solveLoading || selectedIsSolved}
  title={selectedIsSolved ? "Already solved" : solveLoading ? "Saving..." : "Mark as solved"}
>
  {selectedIsSolved ? "Solved" : solveLoading ? "Saving..." : "Mark Solved"}
</button>
'@

$raw = [regex]::Replace($raw, $buttonPattern, $buttonReplacement, 1)

Write-Host "OK: Solve button label UX polished." -ForegroundColor Green

Set-Content -Path $ui -Value $raw -Encoding UTF8
Write-Host "OK: Patch complete: $ui" -ForegroundColor Green
Write-Host "OK: If anything looks wrong, restore backup: $backup" -ForegroundColor Yellow
