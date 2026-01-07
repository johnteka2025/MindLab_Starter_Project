# PATCH_16D_fix_progressPersistence_duplicate_path.ps1
# Goal: Remove duplicate `const path = require("path");` lines from backend\src\progressPersistence.cjs
# Golden Rules: correct paths, backup with timestamp, sanity checks, return to project root.

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: $p" }
}

$ROOT   = "C:\Projects\MindLab_Starter_Project"
$TARGET = Join-Path $ROOT "backend\src\progressPersistence.cjs"

Assert-Path $ROOT   "project root"
Assert-Path $TARGET "progressPersistence.cjs"

# Backup
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "${TARGET}.bak_fix_pathdup_${ts}"
Copy-Item $TARGET $backup -Force
Write-Host "Backup created: $backup" -ForegroundColor Green

# Read file (RAW only; no Delimiter)
$text = Get-Content -Path $TARGET -Raw -Encoding UTF8

# Normalize line endings to `n for processing
$text = $text -replace "`r`n", "`n"
$lines = $text -split "`n"

# Match: const path = require("path");
# Supports spaces and either quote type.
$regexPath = '^\s*const\s+path\s*=\s*require\(\s*["'']path["'']\s*\)\s*;\s*$'

# Find occurrences
$occ = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match $regexPath) {
    $occ += ($i + 1) # 1-based line numbers
  }
}

if ($occ.Count -le 1) {
  Write-Host "No duplicate path require found. Occurrences: $($occ.Count)" -ForegroundColor Yellow
  if ($occ.Count -eq 1) {
    Write-Host "Sanity: path require line number remaining: $($occ[0])" -ForegroundColor Cyan
  } else {
    Write-Host "Sanity WARNING: path require not found at all." -ForegroundColor Yellow
  }
  Set-Location $ROOT
  Write-Host "Returned to project root: $ROOT" -ForegroundColor Cyan
  exit 0
}

# Keep the first occurrence, remove the rest
$keep = $occ[0]
$remove = $occ[1..($occ.Count-1)]

Write-Host "Keeping path require at line: $keep" -ForegroundColor Cyan
Write-Host "Removing duplicate path require line(s): $($remove -join ', ')" -ForegroundColor Cyan

$new = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) {
  $ln = $i + 1
  if ($remove -contains $ln) { continue }
  $new.Add($lines[$i])
}

# Write back (UTF8) with trailing newline
$out = ($new -join "`n").TrimEnd() + "`n"
Set-Content -Path $TARGET -Value $out -Encoding UTF8

# Sanity check after write
$afterText = Get-Content -Path $TARGET -Raw -Encoding UTF8
$afterText = $afterText -replace "`r`n", "`n"
$afterLines = $afterText -split "`n"

$afterOcc = @()
for ($i = 0; $i -lt $afterLines.Count; $i++) {
  if ($afterLines[$i] -match $regexPath) {
    $afterOcc += ($i + 1)
  }
}

Write-Host "PATCH_16D GREEN: Removed $($remove.Count) duplicate path require line(s)." -ForegroundColor Green
Write-Host "Sanity: path require line numbers remaining:" -ForegroundColor Cyan
if ($afterOcc.Count -eq 0) {
  Write-Host "(none found)  <-- WARNING, path require missing!" -ForegroundColor Yellow
} else {
  $afterOcc | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
}

Set-Location $ROOT
Write-Host "Returned to project root: $ROOT" -ForegroundColor Cyan
