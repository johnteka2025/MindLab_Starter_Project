# archive_duplicates_2025-12-27.ps1
# Intent: Move known non-authoritative duplicates into a date-stamped archive folder (no deletions)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = 'C:\Projects\MindLab_Starter_Project'
if (-not (Test-Path -LiteralPath $root)) { throw ("Root missing: {0}" -f $root) }
Set-Location -LiteralPath $root

$date = Get-Date -Format 'yyyy-MM-dd'
$archiveRoot = Join-Path $root ("ARCHIVE_DUPLICATES_{0}" -f $date)
New-Item -ItemType Directory -Force -Path $archiveRoot | Out-Null

$log = Join-Path $archiveRoot ("ARCHIVE_LOG_{0}.txt" -f $date)
"Archive Duplicates Log" | Out-File $log -Encoding UTF8
("Date: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) | Out-File $log -Append
("Project Root: {0}" -f $root) | Out-File $log -Append
("Archive Root: {0}" -f $archiveRoot) | Out-File $log -Append
"------------------------------------------------------------" | Out-File $log -Append

function Move-ToArchive {
  param([Parameter(Mandatory=$true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    ("SKIP (missing): {0}" -f $Path) | Out-File $log -Append
    return
  }

  $rel = $Path.Substring($root.Length).TrimStart('\')
  $dest = Join-Path $archiveRoot $rel
  $destDir = Split-Path -Parent $dest
  New-Item -ItemType Directory -Force -Path $destDir | Out-Null

  ("MOVE: {0}" -f $Path) | Out-File $log -Append
  ("  TO: {0}" -f $dest) | Out-File $log -Append

  Move-Item -LiteralPath $Path -Destination $dest -Force
}

# ------------------------------------------------------------
# AUTHORITATIVE KEEP (DO NOT MOVE):
#   backend\src\server.cjs  (entry)
#   backend\src\puzzles.json (active)
#   backend\src\puzzles\_legacy\puzzles.json (legacy fallback)
#   backend\data\progress.json (active)
#   frontend\index.html, frontend\src\main.tsx, frontend\src\App.tsx (entry chain)
#   frontend\src\components\*.tsx (canonical components)
#   frontend\src\daily-challenge\DailyChallengeDetailPage.tsx (canonical)
# ------------------------------------------------------------

# 1) Archive entire snapshot/backup folders that create duplicates (safe, not runtime-used)
Move-ToArchive -Path (Join-Path $root 'frontend_20251029_090727')
Move-ToArchive -Path (Join-Path $root 'backend_backup_phase12_20251126_202223')

# 2) Remove dangerous “same-name different folder” live duplicates (keep canonical ones)
# Frontend components: keep under frontend\src\components
Move-ToArchive -Path (Join-Path $root 'frontend\src\ProgressPanel.tsx')
Move-ToArchive -Path (Join-Path $root 'frontend\src\GamePanel.tsx')

# Stray root-level page duplicate: keep the one under frontend\src\daily-challenge
Move-ToArchive -Path (Join-Path $root 'DailyChallengeDetailPage.tsx')

# Backend progress: keep backend\data\progress.json, archive backend\src\data\progress.json
Move-ToArchive -Path (Join-Path $root 'backend\src\data\progress.json')

# Backend puzzles: keep backend\src\puzzles.json + backend\src\puzzles\_legacy\puzzles.json
# Archive backend\data\puzzles.json (not used by runtime) + backup copy already handled above
Move-ToArchive -Path (Join-Path $root 'backend\data\puzzles.json')

# 3) Tooling script duplicates (choose ONE canonical location)
# Keep root scripts; archive duplicates under subfolders that create confusion.
Move-ToArchive -Path (Join-Path $root 'backend\run_frontend.ps1')
Move-ToArchive -Path (Join-Path $root 'tests\run_tests.ps1')
Move-ToArchive -Path (Join-Path $root 'tools\Sanity.ps1.ps1')

# 4) Env duplicates (choose canonical)
# Keep frontend\.env.local; archive root-level .env.local (avoid ambiguity)
Move-ToArchive -Path (Join-Path $root '.env.local')

"------------------------------------------------------------" | Out-File $log -Append
"DONE" | Out-File $log -Append
notepad $log
