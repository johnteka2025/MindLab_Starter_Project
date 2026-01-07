param(
  [switch]$IncludeArchives,
  [switch]$IncludeNodeModules
)

# run_duplicate_scan.ps1
# MindLab - Duplicate Scan (Simple, Strict, Documentation-Ready)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------
# Config
# -----------------------------
$root = 'C:\Projects\MindLab_Starter_Project'

# Default exclusions (daily gate)
$defaultExcludeDirNames = @(
  'node_modules',
  'backups',
  '_snapshots',
  '_quarantine',
  'dist',
  'build',
  '.git'
)

# -----------------------------
# Pre-flight (Path certainty)
# -----------------------------
if (-not (Test-Path -LiteralPath $root)) {
  throw ("Project root not found: {0}" -f $root)
}

$startLocation = Get-Location

try {
  Set-Location -LiteralPath $root

  # Documentation folder
  $docPath = Join-Path -Path $root -ChildPath 'daily_closeout_docs'
  New-Item -ItemType Directory -Force -Path $docPath | Out-Null

  $date = Get-Date -Format 'yyyy-MM-dd'
  $mode = @()
  if ($IncludeArchives) { $mode += 'IncludeArchives' } else { $mode += 'LiveOnly' }
  if ($IncludeNodeModules) { $mode += 'IncludeNodeModules' } else { $mode += 'NoNodeModules' }
  $modeTag = ($mode -join '_')

  $outFile = Join-Path -Path $docPath -ChildPath ("Duplicate_Scan_Result_{0}_{1}.txt" -f $date, $modeTag)

  # Build exclusion set based on parameters
  $exclude = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::OrdinalIgnoreCase)
  foreach ($d in $defaultExcludeDirNames) { [void]$exclude.Add($d) }

  if ($IncludeArchives) {
    [void]$exclude.Remove('backups')
    [void]$exclude.Remove('_snapshots')
    [void]$exclude.Remove('_quarantine')
  }
  if ($IncludeNodeModules) {
    [void]$exclude.Remove('node_modules')
  }

  # Header
  "MindLab Duplicate File Scan" | Out-File -FilePath $outFile -Encoding UTF8
  ("Date: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) | Out-File -FilePath $outFile -Append -Encoding UTF8
  ("Project Root: {0}" -f $root) | Out-File -FilePath $outFile -Append -Encoding UTF8
  ("Mode: {0}" -f $modeTag) | Out-File -FilePath $outFile -Append -Encoding UTF8
  "Excluded folders:" | Out-File -FilePath $outFile -Append -Encoding UTF8
  foreach ($x in ($exclude | Sort-Object)) { ("  - {0}" -f $x) | Out-File -FilePath $outFile -Append -Encoding UTF8 }
  "------------------------------------------------------------" | Out-File -FilePath $outFile -Append -Encoding UTF8

  # Enumerate files and exclude by directory name
  $files =
    Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
      $dir = $_.Directory
      while ($null -ne $dir) {
        if ($exclude.Contains($dir.Name)) { return $false }
        $dir = $dir.Parent
      }
      return $true
    }

  # Duplicates by filename
  $duplicates =
    $files |
    Group-Object -Property Name |
    Where-Object { $_.Count -gt 1 } |
    Sort-Object -Property Count -Descending

  # Output (NO reliance on .Count for gating)
  if ($null -eq $duplicates -or $duplicates.Length -eq 0) {
    "RESULT: ✅ NO DUPLICATE FILES FOUND (in selected mode)" | Out-File -FilePath $outFile -Append -Encoding UTF8
  }
  else {
    foreach ($group in $duplicates) {
      "" | Out-File -FilePath $outFile -Append -Encoding UTF8
      ("DUPLICATE FILE NAME: {0}" -f $group.Name) | Out-File -FilePath $outFile -Append -Encoding UTF8
      ("COUNT: {0}" -f $group.Count) | Out-File -FilePath $outFile -Append -Encoding UTF8
      "LOCATIONS:" | Out-File -FilePath $outFile -Append -Encoding UTF8
      foreach ($f in $group.Group) {
        ("  - {0}" -f $f.FullName) | Out-File -FilePath $outFile -Append -Encoding UTF8
      }
    }
  }

  "------------------------------------------------------------" | Out-File -FilePath $outFile -Append -Encoding UTF8
  "END OF SCAN" | Out-File -FilePath $outFile -Append -Encoding UTF8

  notepad $outFile
  Write-Host ("Wrote scan results to: {0}" -f $outFile)
}
finally {
  Set-Location -LiteralPath $startLocation
}
