# PATCH_STEP9_Add_Daily_Refresh_Button.ps1
# Purpose: Add a "Refresh Progress" button to DailyChallengeDetailPage.tsx
# Method: Minimal + reversible + no new imports (uses window.location.reload()).
# Golden Rules: backup-first, stop-on-mismatch, no guessing

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) {
  Write-Host "ERROR: $msg" -ForegroundColor Red
  exit 1
}
function Ok([string]$msg) {
  Write-Host "OK: $msg" -ForegroundColor Green
}

$PROJECT_ROOT = "C:\Projects\MindLab_Starter_Project"
$FILE = Join-Path $PROJECT_ROOT "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"

if (-not (Test-Path $PROJECT_ROOT)) { Fail "Project root not found: $PROJECT_ROOT" }
if (-not (Test-Path $FILE)) { Fail "Target file not found: $FILE" }

# Backup
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$FILE.bak_$ts"
Copy-Item $FILE $bak -Force
Ok "Backup created: $bak"

$content = Get-Content $FILE -Raw

# Guard: avoid double-patching
if ($content -match 'handleRefreshProgress' -or $content -match 'Refresh Progress') {
  Fail "Patch appears already applied (found existing handleRefreshProgress or 'Refresh Progress'). Aborting to prevent duplicates."
}

# 1) Insert handler before the first 'return ('
$handlerBlock = @"
const handleRefreshProgress = () => {
  // Minimal, safe refresh: reload page so Daily UI re-fetches latest progress
  window.location.reload();
};

"@

$idxReturn = $content.IndexOf("return (")
if ($idxReturn -lt 0) {
  Fail "Could not find 'return (' in the component. Aborting to avoid corrupting the file."
}

# Insert handler if it doesn't already exist (guarded above)
$content2 = $content.Insert($idxReturn, $handlerBlock)

# 2) Insert button into JSX near the first 'Progress:' label
# We require a recognizable 'Progress:' string to anchor insertion
$anchor = "Progress:"
$anchorPos = $content2.IndexOf($anchor)
if ($anchorPos -lt 0) {
  Fail "Could not find 'Progress:' label in JSX to anchor button insertion. Aborting (no guessing)."
}

# Find end of the line containing 'Progress:' to insert after it
$lineEnd = $content2.IndexOf("`n", $anchorPos)
if ($lineEnd -lt 0) { $lineEnd = $content2.Length - 1 }

$buttonBlock = @"
{" "}
<button type="button" onClick={handleRefreshProgress}>
  Refresh Progress
</button>
"@

$content3 = $content2.Insert($lineEnd + 1, $buttonBlock)

# Write back
Set-Content $FILE $content3 -Encoding UTF8
Ok "Inserted handler + Refresh Progress button into DailyChallengeDetailPage.tsx"

Ok "Patch completed successfully."
