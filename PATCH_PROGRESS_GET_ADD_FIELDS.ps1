# PATCH_PROGRESS_GET_ADD_FIELDS.ps1
# Purpose: Update GET /progress response to include streak + solvedToday + totalSolved.
# Golden Rules: backup first, exact/single match only, abort if not exact.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $projectRoot "backend\src\progressRoutes.cjs"

if (!(Test-Path $target)) {
  throw "ERROR: Target file not found: $target"
}

# Backup (Golden Rule)
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$target.bak_add_fields_$stamp"
Copy-Item $target $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$src = Get-Content $target -Raw

# Match the CURRENT handler shape you showed (must match EXACTLY ONCE).
# We use a whitespace-tolerant regex but anchored tightly to this handler content.
$pattern = @'
(?s)
app\.get\("/progress",\s*\(_req,\s*res\)\s*=>\s*\{\s*
clampProgress\(\);\s*
const\s+p\s*=\s*globalThis\.__mindlabProgress;\s*
return\s+res\.json\(\{\s*
total:\s*p\.total,\s*
solved:\s*p\.solved,\s*
solvedIds:\s*solvedIdsArray\(\),\s*
\}\);\s*
\}\);
'@.Trim()

$matches = [regex]::Matches($src, $pattern)
if ($matches.Count -ne 1) {
  throw "ERROR: Could not match GET /progress handler EXACTLY once. Found: $($matches.Count). Aborting (no guessing)."
}

$replacement = @'
app.get("/progress", (_req, res) => {
  clampProgress();
  const p = globalThis.__mindlabProgress;
  return res.json({
    total: p.total,
    solved: p.solved,
    solvedToday: p.solvedToday,
    totalSolved: p.totalSolved,
    streak: p.streak,
    solvedIds: solvedIdsArray(),
  });
});
'@

$patched = [regex]::Replace($src, $pattern, $replacement, 1)

if ($patched -eq $src) {
  throw "ERROR: Patch produced no changes (unexpected). Aborting."
}

Set-Content -Path $target -Value $patched -Encoding UTF8
Write-Host "OK: Patched GET /progress to include streak/solvedToday/totalSolved." -ForegroundColor Green
Write-Host "OK: Patch completed successfully." -ForegroundColor Green
