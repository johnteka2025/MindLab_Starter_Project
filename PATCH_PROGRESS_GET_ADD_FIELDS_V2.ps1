# PATCH_PROGRESS_GET_ADD_FIELDS_V2.ps1
# Goal: Add solvedToday/totalSolved/streak to GET /progress response.
# Golden Rules: backup first; patch only if exactly one match; no guessing.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $projectRoot "backend\src\progressRoutes.cjs"

if (!(Test-Path $target)) { throw "ERROR: File not found: $target" }

# Backup
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$target.bak_add_fields_v2_$stamp"
Copy-Item $target $backup -Force
Write-Host "OK: Backup created: $backup" -ForegroundColor Green

$src = Get-Content $target -Raw

# Match the GET /progress handler by:
# 1) locating app.get("/progress"
# 2) locating the return res.json({ ... });
# 3) capturing the object body so we can inject fields before solvedIds or before closing.
$pattern = '(?s)app\.get\("/progress",\s*\(_req,\s*res\)\s*=>\s*\{.*?return\s+res\.json\(\{\s*(?<body>.*?)\s*\}\);\s*\}\);'

$matches = [regex]::Matches($src, $pattern)
if ($matches.Count -ne 1) {
  throw "ERROR: Could not match GET /progress handler EXACTLY once. Found: $($matches.Count). Aborting (no guessing)."
}

$body = $matches[0].Groups["body"].Value

# Guard: do not double-insert
if ($body -match '\bstreak\s*:') {
  Write-Host "OK: GET /progress already contains streak (no changes needed)." -ForegroundColor Green
  exit 0
}

# Prefer insertion before solvedIds if present, otherwise append at end.
$insertion = @'
solvedToday: p.solvedToday,
    totalSolved: p.totalSolved,
    streak: p.streak,
'@

if ($body -match '\bsolvedIds\s*:') {
  $newBody = [regex]::Replace($body, '(\bsolvedIds\s*:)', "$insertion`n    `$1", 1)
} else {
  # Append before end of object body
  $newBody = $body.TrimEnd() + "`n    " + $insertion.TrimEnd()
}

# Rebuild the handler content with the modified body
$replacement = $matches[0].Value -replace [regex]::Escape($body), [regex]::Escape($newBody)
# Above escape/replace can be tricky; use direct assembly instead:
$fullNew = $matches[0].Value
$fullNew = $fullNew.Substring(0, $fullNew.IndexOf($body)) + $newBody + $fullNew.Substring($fullNew.IndexOf($body) + $body.Length)

$patched = [regex]::Replace($src, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $fullNew }, 1)

if ($patched -eq $src) { throw "ERROR: Patch produced no changes (unexpected). Aborting." }

Set-Content -Path $target -Value $patched -Encoding UTF8
Write-Host "OK: Patched GET /progress to include solvedToday/totalSolved/streak." -ForegroundColor Green
Write-Host "OK: Patch completed successfully." -ForegroundColor Green
