param(
    [switch]$TraceOn
)

# MindLab - Phase 7: Snapshot & Backup (Safe ZIP version)
# Fixes the file-lock issue by creating the ZIP in TEMP first.

$ErrorActionPreference = "Stop"

$root         = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir       = Join-Path $root "logs"
$snapshotDir  = Join-Path $root "snapshots"

New-Item -ItemType Directory -Path $logDir -Force      | Out-Null
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

Write-Host "=== MindLab Phase 7 - Snapshot & Backup (Safe ZIP) ===" -ForegroundColor Cyan

#######################################################################
# STEP 0 — Daily Start
#######################################################################

$dsTs  = Get-Date -Format "yyyyMMdd_HHmmss"
$dsLog = Join-Path $logDir ("phase7_daily_start_{0}.log" -f $dsTs)

Write-Host "`nSTEP 0 — Running daily start..." -ForegroundColor Cyan
try {
    .\mindlab_daily_start.ps1 -TraceOn *>&1 | Tee-Object -FilePath $dsLog
    $dailyExit = $LASTEXITCODE
    if ($null -eq $dailyExit) { $dailyExit = 0 }
}
catch {
    Write-Host ("Daily start ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}

if ($dailyExit -ne 0) {
    Write-Host "Daily start FAILED. Check logs." -ForegroundColor Red
    exit 1
}

Write-Host "Daily start PASSED." -ForegroundColor Green

#######################################################################
# STEP 1 — Independent LOCAL + PROD health check
#######################################################################

Write-Host "`nSTEP 1 — Health sanity check..." -ForegroundColor Cyan

$localBase = "http://localhost:8085"
$prodBase  = "https://mindlab-swpk.onrender.com"

$localOK = $false
$prodOK  = $false

try {
    $r = Invoke-WebRequest -Uri "$localBase/health" -UseBasicParsing -TimeoutSec 10
    if ($r.StatusCode -eq 200) { $localOK = $true }
    Write-Host "LOCAL /health -> HTTP $($r.StatusCode)" -ForegroundColor Green
}
catch {
    Write-Host ("LOCAL health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

try {
    $p = Invoke-WebRequest -Uri "$prodBase/health" -UseBasicParsing -TimeoutSec 15
    if ($p.StatusCode -eq 200) { $prodOK = $true }
    Write-Host "PROD /health -> HTTP $($p.StatusCode)" -ForegroundColor Green
}
catch {
    Write-Host ("PROD health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

if (-not $localOK -or -not $prodOK) {
    Write-Host "Health check FAILED. Snapshot aborted." -ForegroundColor Red
    exit 1
}

Write-Host "Health sanity PASSED for LOCAL and PROD." -ForegroundColor Green

#######################################################################
# STEP 2 — Create safe ZIP snapshot
#######################################################################

Write-Host "`nSTEP 2 — Creating safe ZIP snapshot..." -ForegroundColor Cyan

$snapTs        = Get-Date -Format "yyyyMMdd_HHmmss"
$snapshotName  = "MindLab_snapshot_{0}.zip" -f $snapTs
$finalSnapshot = Join-Path $snapshotDir $snapshotName

# SAFE TEMP ZIP FILE
$tempZip = Join-Path $env:TEMP ("MindLab_snapshot_temp_{0}.zip" -f $snapTs)

Write-Host "Temp ZIP:   $tempZip" -ForegroundColor DarkGray
Write-Host "Final ZIP:  $finalSnapshot" -ForegroundColor DarkGray

try {
    # Remove old temp file if it exists
    if (Test-Path $tempZip) { Remove-Item $tempZip -Force }

    # Create ZIP in TEMP (no Windows Defender locking)
    Compress-Archive -Path (Join-Path $root '*') -DestinationPath $tempZip -Force

    # Move ZIP to snapshots folder after compression is successful
    Move-Item -Path $tempZip -Destination $finalSnapshot -Force

    Write-Host "Snapshot created successfully!" -ForegroundColor Green
    Write-Host "Snapshot location: $finalSnapshot" -ForegroundColor Green

    Write-Host "[RESULT] Phase 7 - Snapshot & Backup: PASSED" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ("Snapshot ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 7 - Snapshot & Backup: FAILED" -ForegroundColor Red
    exit 1
}
