# Phase 1.2C — Create Baseline Snapshot (clean, reproducible)
# Location: C:\Projects\MindLab_Starter_Project\phase_1_2C_create_baseline_snapshot.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startDir = Get-Location
try {
  $projectRoot = $PSScriptRoot
  if (-not $projectRoot) { throw "PSScriptRoot is empty. Run this script from a file, not pasted blocks." }

  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $snapRoot = Join-Path $projectRoot "backups\baseline_snapshots"
  $snapDir  = Join-Path $snapRoot ("baseline_" + $stamp)

  New-Item -ItemType Directory -Force -Path $snapDir | Out-Null

  Write-Host "=== BASELINE SNAPSHOT (Phase 1.2C) ===" -ForegroundColor Cyan
  Write-Host "[INFO] ProjectRoot: $projectRoot" -ForegroundColor Gray
  Write-Host "[INFO] SnapshotDir: $snapDir" -ForegroundColor Gray

  # What we snapshot (minimal but useful)
  $items = @(
    "backend\src",
    "backend\package.json",
    "backend\package-lock.json",
    "backend\.env.example",
    "frontend\src",
    "frontend\package.json",
    "frontend\package-lock.json",
    "run_daily_check.ps1"
  )

  $copied = @()
  foreach ($rel in $items) {
    $src = Join-Path $projectRoot $rel
    if (Test-Path $src) {
      $dst = Join-Path $snapDir $rel
      $dstParent = Split-Path $dst -Parent
      New-Item -ItemType Directory -Force -Path $dstParent | Out-Null

      if ((Get-Item $src).PSIsContainer) {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
      } else {
        Copy-Item -Path $src -Destination $dst -Force
      }
      $copied += $rel
      Write-Host "[OK] Copied: $rel" -ForegroundColor Green
    } else {
      Write-Host "[WARN] Missing (skipped): $rel" -ForegroundColor Yellow
    }
  }

  # Manifest
  $manifestPath = Join-Path $snapDir "manifest.txt"
  $manifestLines = @()
  $manifestLines += "MindLab Baseline Snapshot"
  $manifestLines += "Timestamp: $stamp"
  $manifestLines += "ProjectRoot: $projectRoot"
  $manifestLines += ""
  $manifestLines += "Copied items:"
  $manifestLines += ($copied | Sort-Object | ForEach-Object { " - " + $_ })

  Set-Content -Path $manifestPath -Value $manifestLines -Encoding UTF8
  Write-Host "[OK] Manifest created: $manifestPath" -ForegroundColor Green

  # Hashes
  $hashPath = Join-Path $snapDir "hashes_sha256.txt"
  Write-Host "[INFO] Generating SHA256 hashes..." -ForegroundColor Yellow

  $files = Get-ChildItem -Path $snapDir -Recurse -File
  $hashLines = foreach ($f in $files) {
    $h = Get-FileHash -Algorithm SHA256 -Path $f.FullName
    $relPath = $f.FullName.Substring($snapDir.Length).TrimStart('\')
    ("{0}  {1}" -f $h.Hash, $relPath)
  }

  Set-Content -Path $hashPath -Value $hashLines -Encoding UTF8
  Write-Host "[OK] Hash file created: $hashPath" -ForegroundColor Green

  Write-Host ""
  Write-Host "=== SNAPSHOT PROOF ===" -ForegroundColor Cyan
  Write-Host ("Snapshot: " + $snapDir) -ForegroundColor Gray
  Write-Host ("Files hashed: " + $files.Count) -ForegroundColor Gray
  Write-Host ""
  Write-Host "NEXT: Proceed to PHASE 2 — New test coverage." -ForegroundColor Yellow

} finally {
  Set-Location $startDir
  Write-Host ("[INFO] Returned to: " + (Get-Location).Path) -ForegroundColor Cyan
  Read-Host "Press ENTER to continue"
}
