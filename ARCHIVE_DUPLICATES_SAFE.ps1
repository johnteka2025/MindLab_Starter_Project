# ARCHIVE_DUPLICATES_SAFE.ps1
# Golden Rules:
# - No guessing (we scan + log)
# - No deletes (only Move-Item)
# - Dry-run supported (-WhatIf)
# - Always return to project root

[CmdletBinding()]
param(
  [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: ${p}" }
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
Assert-Path $ROOT "project root"
Set-Location $ROOT

$ts = Get-Date -Format "yyyyMMdd_HHmmss"

$reportsDir = Join-Path $ROOT "reports"
if (-not (Test-Path $reportsDir)) { New-Item -ItemType Directory -Path $reportsDir | Out-Null }

$quarantineDir = Join-Path $ROOT ("_quarantine\duplicates_{0}" -f $ts)
New-Item -ItemType Directory -Path $quarantineDir -Force | Out-Null

$log = Join-Path $reportsDir ("ARCHIVE_DUPLICATES_{0}.txt" -f $ts)

"ARCHIVE DUPLICATES SAFE - $ts" | Out-File $log -Encoding utf8 -Force
"Project Root: $ROOT" | Out-File $log -Encoding utf8 -Append
"Quarantine:   $quarantineDir" | Out-File $log -Encoding utf8 -Append
"WhatIf:       $WhatIf" | Out-File $log -Encoding utf8 -Append
"" | Out-File $log -Encoding utf8 -Append

# ---------- Rules for what counts as a "duplicate" ----------
# 1) .bak* files: duplicates grouped by "base file" (file name before .bak...)
# 2) PATCH_*.ps1: duplicates grouped by the patch number prefix (PATCH_12, PATCH_12B, etc.)
# 3) Files ending with timestamp suffixes: we treat as versions, keep newest in place.

# Helper: get a "base key" for backups like Progress.tsx.bak_status_20251224_150630
function Get-BackupBaseKey([string]$name) {
  # Split at ".bak" and keep left side as base
  $idx = $name.IndexOf(".bak")
  if ($idx -gt 0) { return $name.Substring(0, $idx) }
  return $name
}

# Helper: safe move that preserves relative path structure
function Move-ToQuarantine([string]$fullPath) {
  $rel = Resolve-Path $fullPath | ForEach-Object {
    $_.Path.Substring($ROOT.Length).TrimStart("\")
  }
  $dest = Join-Path $quarantineDir $rel
  $destDir = Split-Path $dest -Parent
  if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

  if ($WhatIf) {
    "WHATIF MOVE: $fullPath -> $dest" | Out-File $log -Encoding utf8 -Append
  } else {
    Move-Item -LiteralPath $fullPath -Destination $dest -Force
    "MOVED: $fullPath -> $dest" | Out-File $log -Encoding utf8 -Append
  }
}

# ---------- A) Handle .bak* duplicates ----------
Write-Host "=== A) Scanning .bak* duplicates (keep newest per base file) ===" -ForegroundColor Cyan
$bakFiles = Get-ChildItem $ROOT -Recurse -File -Include "*.bak*" -ErrorAction SilentlyContinue

# Group by base name, keep newest, quarantine rest
$bakGroups = $bakFiles | Group-Object { Get-BackupBaseKey($_.Name) }

$bakMoved = 0
foreach ($g in $bakGroups) {
  if ($g.Count -le 1) { continue }

  # Sort newest first by LastWriteTime, keep first, archive the rest
  $sorted = $g.Group | Sort-Object LastWriteTime -Descending
  $keep = $sorted[0]
  $toMove = $sorted | Select-Object -Skip 1

  "" | Out-File $log -Encoding utf8 -Append
  "BACKUP GROUP: $($g.Name)  (count=$($g.Count))" | Out-File $log -Encoding utf8 -Append
  "KEEP:  $($keep.FullName) | $($keep.LastWriteTime)" | Out-File $log -Encoding utf8 -Append

  foreach ($f in $toMove) {
    Move-ToQuarantine $f.FullName
    $bakMoved++
  }
}

# ---------- B) Detect PATCH duplicates (same patch prefix) ----------
Write-Host "=== B) Scanning PATCH duplicates in project root ===" -ForegroundColor Cyan
$patches = Get-ChildItem $ROOT -File -Filter "PATCH_*.ps1" -ErrorAction SilentlyContinue

# Key: first token up to next underscore after PATCH_xx... (e.g., PATCH_12, PATCH_12B, PATCH_08)
function Get-PatchKey([string]$name) {
  if ($name -match "^(PATCH_\d+[A-Z]?)_") { return $Matches[1] }
  if ($name -match "^(PATCH_\d+)_") { return $Matches[1] }
  return $name
}

$patchGroups = $patches | Group-Object { Get-PatchKey($_.Name) }

$patchMoved = 0
foreach ($g in $patchGroups) {
  if ($g.Count -le 1) { continue }

  # Keep newest by LastWriteTime
  $sorted = $g.Group | Sort-Object LastWriteTime -Descending
  $keep = $sorted[0]
  $toMove = $sorted | Select-Object -Skip 1

  "" | Out-File $log -Encoding utf8 -Append
  "PATCH GROUP: $($g.Name)  (count=$($g.Count))" | Out-File $log -Encoding utf8 -Append
  "KEEP:  $($keep.FullName) | $($keep.LastWriteTime)" | Out-File $log -Encoding utf8 -Append

  foreach ($f in $toMove) {
    Move-ToQuarantine $f.FullName
    $patchMoved++
  }
}

# ---------- Summary ----------
"" | Out-File $log -Encoding utf8 -Append
"SUMMARY:" | Out-File $log -Encoding utf8 -Append
"Moved .bak duplicates:   $bakMoved" | Out-File $log -Encoding utf8 -Append
"Moved PATCH duplicates:  $patchMoved" | Out-File $log -Encoding utf8 -Append
"" | Out-File $log -Encoding utf8 -Append
"Log: $log" | Out-File $log -Encoding utf8 -Append

Set-Location $ROOT

Write-Host "ARCHIVE_DUPLICATES complete." -ForegroundColor Green
Write-Host ("Moved .bak duplicates:  {0}" -f $bakMoved) -ForegroundColor Green
Write-Host ("Moved PATCH duplicates: {0}" -f $patchMoved) -ForegroundColor Green
Write-Host "Log written: $log" -ForegroundColor Green
Write-Host "Quarantine folder: $quarantineDir" -ForegroundColor Green
Write-Host "Returned to project root: $ROOT" -ForegroundColor Green
