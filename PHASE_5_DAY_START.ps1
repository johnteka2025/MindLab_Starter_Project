# PHASE_5_DAY_START.ps1
# Run from: C:\Projects\MindLab_Starter_Project
$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: $p" }
}

try {
  $root = "C:\Projects\MindLab_Starter_Project"
  Set-Location $root

  Write-Host "=== PHASE 5 DAY START (Golden Rules Gate) ===" -ForegroundColor Cyan
  Write-Host ("Project root: {0}" -f (Get-Location)) -ForegroundColor Gray

  # 1) Phase 4 must be frozen
  Assert-Path ".\ARCHIVE_PHASE_4" "ARCHIVE_PHASE_4 folder"
  Assert-Path ".\docs\PHASE_4_PERSISTENCE_CONTRACTS.md" "Phase 4 contract"
  Write-Host "Phase 4 freeze: OK" -ForegroundColor Green

  # 2) Duplicate / broken detection (lightweight guard)
  $broken = Get-ChildItem -File -Recurse -Filter "*BROKEN*" -ErrorAction SilentlyContinue
  if ($broken.Count -gt 0) {
    Write-Host ("WARNING: Found {0} BROKEN file(s). Leave them quarantined; do not execute them." -f $broken.Count) -ForegroundColor Yellow
  } else {
    Write-Host "Broken file scan: OK (none found)" -ForegroundColor Green
  }

  # 3) Backend reachability
  Write-Host "Backend health check..." -ForegroundColor Cyan
  $health = Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing
  if ($health.StatusCode -ne 200) { throw "Backend health is not 200. Got $($health.StatusCode)" }
  Write-Host "Backend health: 200 OK" -ForegroundColor Green

  # 4) Progress endpoint + disk schema guard
  Assert-Path ".\backend\src\data\progress.json" "progress.json"
  $apiProg = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
  if ($apiProg.StatusCode -ne 200) { throw "/progress is not 200. Got $($apiProg.StatusCode)" }
  Write-Host "/progress: 200 OK" -ForegroundColor Green

  $diskText = Get-Content ".\backend\src\data\progress.json" -Raw
  $disk = $diskText | ConvertFrom-Json

  foreach ($k in @("total","solved","solvedToday","totalSolved","streak","solvedIds","solvedPuzzleIds")) {
    if (-not ($disk.PSObject.Properties.Name -contains $k)) { throw "progress.json missing key: $k" }
  }
  if ($disk.solvedPuzzleIds -eq $null) { throw "progress.json solvedPuzzleIds is null" }

  Write-Host "Disk schema: OK" -ForegroundColor Green

  Write-Host "PHASE_5_DAY_START GREEN: safe to proceed with Phase 5 work." -ForegroundColor Green
  Write-Host ("Returned to project root: {0}" -f $root) -ForegroundColor DarkGreen
}
catch {
  Write-Host ("PHASE_5_DAY_START ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
}
finally {
  Set-Location "C:\Projects\MindLab_Starter_Project"
}
