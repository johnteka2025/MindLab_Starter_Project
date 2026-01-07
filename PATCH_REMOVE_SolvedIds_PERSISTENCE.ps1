# PATCH_REMOVE_SolvedIds_PERSISTENCE.ps1
# Goal:
# 1) Remove persisted "solvedIds" state mutation in /progress/reset (legacy, confusing)
# 2) Add a hard safety: delete p.solvedIds inside clampProgress() so it never persists again
# Golden Rules: backup-first, exact-match edits only, abort on ambiguity.

$ErrorActionPreference = "Stop"

function Ok($msg) { Write-Host "OK: $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }
function Err($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }

$root = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $root "backend\src\progressRoutes.cjs"

if (!(Test-Path $target)) {
  Err "Target file not found: $target"
  exit 1
}

# Backup
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$target.bak_remove_solvedIds_$stamp"
Copy-Item $target $backup -Force
Ok "Backup created: $backup"

# Read content (raw to preserve formatting)
$content = Get-Content $target -Raw

# ---------- Step 1: Remove solvedIds reset mutation ----------
# We remove EITHER:
#   p.solvedIds = [];
# OR
#   solvedIds: [],
# but ONLY inside the /progress/reset block.
#
# Strategy:
#  - Locate the /progress/reset handler block using a conservative regex
#  - Ensure at least one of those patterns exists inside it
#  - Remove only those lines, preserving everything else

$resetRegex = '(?s)(app\.post\(\s*["'']\/progress\/reset["'']\s*,.*?\)\s*;\s*)'
# The above is too loose because it tries to match until ');' which might be nested.
# We'll instead match from app.post("/progress/reset" ... up to the next '});' on its own indent,
# but since formatting may vary, we will use a safer "block slice" approach:
# Find the starting index of the reset route and then take a window of text forward.

$resetStart = $content.IndexOf('app.post("/progress/reset"')
if ($resetStart -lt 0) { $resetStart = $content.IndexOf("app.post('/progress/reset'") }

if ($resetStart -lt 0) {
  Err 'Could not find app.post("/progress/reset" ... ) in progressRoutes.cjs. Aborting (no guessing).'
  exit 1
}

# Take a window forward to operate within (10k chars is plenty for a route)
$windowLen = [Math]::Min(10000, $content.Length - $resetStart)
$resetWindow = $content.Substring($resetStart, $windowLen)

# Heuristic: end of route is the first occurrence of "});" after start
$endIdx = $resetWindow.IndexOf("});")
if ($endIdx -lt 0) {
  Err 'Could not find the end of the /progress/reset route block (missing "});"). Aborting (no guessing).'
  exit 1
}

$resetBlock = $resetWindow.Substring(0, $endIdx + 3)

# Confirm legacy solvedIds present in reset block
$hasSolvedIdsAssign = $resetBlock -match '(?m)^\s*p\.solvedIds\s*=\s*\[\s*\]\s*;\s*$'
$hasSolvedIdsProp   = $resetBlock -match '(?m)^\s*solvedIds\s*:\s*\[\s*\]\s*,?\s*$'

if (-not ($hasSolvedIdsAssign -or $hasSolvedIdsProp)) {
  Warn 'No "solvedIds" reset mutation found inside /progress/reset. Skipping that removal step.'
} else {
  # Remove those lines ONLY inside the reset block
  $resetBlockNew = $resetBlock
  $resetBlockNew = [regex]::Replace($resetBlockNew, '(?m)^\s*p\.solvedIds\s*=\s*\[\s*\]\s*;\s*\r?\n', '', 1)
  $resetBlockNew = [regex]::Replace($resetBlockNew, '(?m)^\s*solvedIds\s*:\s*\[\s*\]\s*,?\s*\r?\n', '', 1)

  if ($resetBlockNew -eq $resetBlock) {
    Err 'Attempted to remove solvedIds lines but no change occurred. Aborting (no guessing).'
    exit 1
  }

  # Replace the old block with the new block in the full content
  $content = $content.Substring(0, $resetStart) + $resetBlockNew + $content.Substring($resetStart + $resetBlock.Length)
  Ok 'Removed legacy solvedIds reset mutation inside /progress/reset.'
}

# ---------- Step 2: Add delete p.solvedIds inside clampProgress() ----------
# We will insert:
#   if ("solvedIds" in p) delete p.solvedIds;
# right after the line that defines `const p = globalThis.__mindlabProgress;`
#
# Requirements:
# - clampProgress() must exist
# - The exact anchor line must be found once

$clampStart = $content.IndexOf("function clampProgress(")
if ($clampStart -lt 0) {
  Err 'Could not find "function clampProgress(" in progressRoutes.cjs. Aborting (no guessing).'
  exit 1
}

# Ensure anchor exists exactly once (after clampStart window)
$anchorPattern = '(?m)^\s*const\s+p\s*=\s*globalThis\.__mindlabProgress\s*;\s*$'
$anchorMatches = [regex]::Matches($content.Substring($clampStart, [Math]::Min(12000, $content.Length - $clampStart)), $anchorPattern)
if ($anchorMatches.Count -ne 1) {
  Err "Could not uniquely locate anchor line inside clampProgress(): 'const p = globalThis.__mindlabProgress;'. Found $($anchorMatches.Count). Aborting (no guessing)."
  exit 1
}

$anchorValue = $anchorMatches[0].Value
$insertion = $anchorValue + "`r`n" + '  if ("solvedIds" in p) delete p.solvedIds;' + "`r`n"

# Insert only if not already present
if ($content -match '(?m)^\s*if\s*\(\s*["'']solvedIds["'']\s+in\s+p\s*\)\s*delete\s+p\.solvedIds\s*;\s*$') {
  Warn 'delete p.solvedIds safeguard already present. Skipping insertion.'
} else {
  # Replace the first occurrence of the anchor within clampProgress slice
  $slice = $content.Substring($clampStart)
  $sliceNew = [regex]::Replace($slice, $anchorPattern, [regex]::Escape($anchorValue) -replace '\\Q' -replace '\\E', { $anchorValue }, 1)
  # The above approach is messy; do a simpler safe insertion:
  $sliceNew = $slice -replace $anchorPattern, ($insertion.TrimEnd()), 1

  if ($sliceNew -eq $slice) {
    Err "Failed to insert delete p.solvedIds safeguard. Aborting (no guessing)."
    exit 1
  }

  $content = $content.Substring(0, $clampStart) + $sliceNew
  Ok 'Inserted safeguard: delete p.solvedIds inside clampProgress().'
}

# Write back
Set-Content -Path $target -Value $content -Encoding UTF8
Ok "Patch applied successfully: $target"

# Quick verification hints
Write-Host ""
Write-Host "NEXT (must-pass):" -ForegroundColor Cyan
Write-Host "1) Restart backend (or full dev) then run:" -ForegroundColor Cyan
Write-Host '   (Invoke-WebRequest -UseBasicParsing "http://localhost:8085/progress/reset" -Method POST).Content' -ForegroundColor Cyan
Write-Host '   Get-Content "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"' -ForegroundColor Cyan
Write-Host ""
