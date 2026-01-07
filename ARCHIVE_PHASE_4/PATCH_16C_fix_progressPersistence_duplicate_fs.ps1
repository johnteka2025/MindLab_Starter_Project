# PATCH_16C_fix_progressPersistence_duplicate_fs.ps1
# Fix: backend crash "Identifier 'fs' has already been declared"
# Removes duplicate `const fs = require("fs");` lines after the first occurrence.
# Golden rules: backups + sanity + return to root.

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) {
    throw ("Missing required {0}: {1}" -f $label, $p)
  }
}

$root   = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $root "backend\src\progressPersistence.cjs"

Assert-Path $root "project root"
Assert-Path $target "progressPersistence.cjs"

$ts  = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$target.bak_fix_fsdup_$ts"
Copy-Item $target $bak -Force
Write-Host ("Backup created: {0}" -f $bak) -ForegroundColor Green

# Read file preserving content
$raw = Get-Content $target -Raw -Encoding UTF8
$raw = $raw -replace "`r`n", "`n"  # normalize

$lines = $raw -split "`n", -1

# We treat any of these as the fs require line:
# const fs = require("fs");
# const fs=require('fs')
# (spaces vary, quotes vary, semicolon optional)
function Is-FsRequireLine([string]$line) {
  $t = $line.Trim()
  if ($t -match '^const\s+fs\s*=\s*require\(\s*["'']fs["'']\s*\)\s*;?\s*$') { return $true }
  return $false
}

$seen = $false
$out = New-Object System.Collections.Generic.List[string]
$removed = 0

foreach ($line in $lines) {
  if (Is-FsRequireLine $line) {
    if (-not $seen) {
      $seen = $true
      $out.Add($line)
    } else {
      $removed++
      continue
    }
  } else {
    $out.Add($line)
  }
}

if (-not $seen) {
  Write-Host "WARNING: No fs require line found. No changes applied." -ForegroundColor Yellow
} elseif ($removed -eq 0) {
  Write-Host "No duplicate fs require lines found. File unchanged." -ForegroundColor Yellow
} else {
  $final = ($out -join "`r`n")
  [System.IO.File]::WriteAllText($target, $final, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ("PATCH_16C GREEN: Removed {0} duplicate fs require line(s)." -f $removed) -ForegroundColor Green
}

Write-Host "Sanity: fs require line numbers remaining:" -ForegroundColor Cyan
Select-String -Path $target -Pattern 'const\s+fs\s*=\s*require\(' -AllMatches |
  ForEach-Object { $_.LineNumber }

Set-Location $root
Write-Host ("Returned to project root: {0}" -f $root) -ForegroundColor Cyan
