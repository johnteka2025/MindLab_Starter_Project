# PATCH_PROGRESS_GET_ADD_STREAK.ps1
# Goal: Extend GET /progress response to include streak + solvedToday + totalSolved
# Golden Rules: backup first, exact match only, abort if ambiguous.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $projectRoot "backend\src\progressRoutes.cjs"

if (!(Test-Path $target)) {
  throw "Target file not found: $target"
}

# Read file as raw text
$src = Get-Content $target -Raw

# Exact legacy GET /progress block we expect (from your current file)
$pattern = @'
app\.get\("/progress",\s*\(_req,\s*res\)\s*=>\s*\{\s*
\s*clampProgress\(\);\s*
\s*const p = globalThis\.__mindlabProgress;\s*
\s*return res\.json\(\{\s*
\s*total:\s*p\.total,\s*
\s*solved:\s*p\.solved,\s*
\s*solvedIds:\s*solvedIdsArray\(\),\s*
\s*\}\);\s*
\s*\}\);
'@

$rx = New-Object System.Text.RegularExpressions.Regex($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$matches = $rx.Matches($src)

if ($matches.Count -ne 1) {
  throw "Could not match the GET /progress handler EXACTLY once. Found: $($matches.Count). Aborting (no guessing)."
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

# Backup (timestamped)
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$target.bak_add_streak_$ts"
Copy-Item $target $backup -Force

# Apply replace (single occurrence only)
$patched = $rx.Replace($src, $replacement, 1)

# Sanity: ensure streak field exists in patched output
if ($patched -notmatch 'streak:\s*p\.streak') {
  throw "Patch sanity check failed: 'streak: p.streak' not found after patch. Aborting."
}

Set-Content -Path $target -Value $patched -Encoding UTF8

Write-Host "OK: Backup created: $backup" -ForegroundColor Green
Write-Host "OK: Patched GET /progress response to include streak/solvedToday/totalSolved." -ForegroundColor Green
Write-Host "NEXT: Verify by hitting http://localhost:8085/progress and confirming 'streak' exists." -ForegroundColor Yellow
