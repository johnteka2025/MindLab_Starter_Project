$ErrorActionPreference = "Stop"

$path = "C:\Projects\MindLab_Starter_Project\backend\src\progressRoutes.cjs"
if (-not (Test-Path $path)) { throw "Missing file: $path" }

# Backup (Golden Rule)
$stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$path.bak_add_streak_v3_$stamp"
Copy-Item $path $backup -Force

$raw = Get-Content $path -Raw

# Match the GET /progress handler block as a whole (non-greedy).
# Abort unless EXACTLY ONCE.
$blockPattern = 'app\.get\("/progress",\s*\([^\)]*\)\s*=>\s*\{\s*[\s\S]*?\}\s*\);\s*'
$matches = [regex]::Matches($raw, $blockPattern)

if ($matches.Count -ne 1) {
  throw "ERROR: Could not match GET /progress handler EXACTLY once. Found $($matches.Count). Aborting (no guessing). Backup: $backup"
}

$block = $matches[0].Value

# Idempotent: if streak already present in this handler, no changes.
if ($block -match '\bstreak\s*:\s*p\.streak') {
  Write-Host "OK: GET /progress already includes streak. No changes made."
  Write-Host "OK: Backup created: $backup"
  exit 0
}

# Insert `streak: p.streak,` right after `solved: p.solved,` inside THIS block only.
# Abort if the anchor line isn't found EXACTLY ONCE in the handler block.
$anchorPattern = '(\bsolved\s*:\s*p\.solved\s*,)'
$anchorMatches = [regex]::Matches($block, $anchorPattern)

if ($anchorMatches.Count -ne 1) {
  throw "ERROR: Could not find anchor 'solved: p.solved,' exactly once inside GET /progress handler. Found $($anchorMatches.Count). Aborting (no guessing). Backup: $backup"
}

$blockPatched = [regex]::Replace(
  $block,
  $anchorPattern,
  '$1' + "`r`n" + '    streak: p.streak,',
  1
)

# Replace the original block in the file (EXACTLY ONCE by construction)
$rawPatched = $raw.Replace($block, $blockPatched)

Set-Content -Path $path -Value $rawPatched -Encoding UTF8

Write-Host "OK: Patched GET /progress handler to include streak."
Write-Host "OK: Backup created: $backup"
