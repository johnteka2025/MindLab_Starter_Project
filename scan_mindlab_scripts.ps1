# scan_mindlab_scripts.ps1
# Scan MindLab project for duplicate / misplaced scripts and backups

param()
$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Script Sanity Scan ==="

# 1. Project root is where this script lives
$projectRoot = Split-Path -Parent $PSCommandPath
Set-Location $projectRoot

Write-Host "[INFO] Project root : $projectRoot"
Write-Host ""

# 2. Define the canonical scripts expected in project root
$canonicalScripts = @(
    "run_mindlab_daily_routine.ps1",
    "run_daily_ui_test.ps1",
    "run_progress_ui_test.ps1",
    "run_ui_suite.ps1",
    "run_daily_with_error_log.ps1",
    "run_daily_rtf_summary.ps1",
    "run_full_day_stack.ps1",
    "scan_mindlab_scripts.ps1",
    "move_legacy_scripts.ps1"
)

Write-Host "[INFO] Checking canonical scripts in project root..." -ForegroundColor Cyan
Write-Host ""

foreach ($name in $canonicalScripts) {
    $path = Join-Path $projectRoot $name
    if (Test-Path $path) {
        Write-Host ("[OK]      {0}" -f $name) -ForegroundColor Green
    } else {
        Write-Host ("[MISSING] {0}" -f $name) -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[INFO] Scanning for duplicates and backups..." -ForegroundColor Cyan
Write-Host ""

# 3. Find all .ps1 files in the entire project tree
$allPs1 = Get-ChildItem -Path $projectRoot -Filter '*.ps1' -Recurse

# 3a. Group by file name to see duplicates
$grouped = $allPs1 | Group-Object Name

Write-Host "---- Possible duplicates (same file name in multiple folders) ----"
foreach ($g in $grouped) {
    if ($g.Count -gt 1) {
        Write-Host ""
        Write-Host ("File name: {0}" -f $g.Name) -ForegroundColor Yellow
        foreach ($item in $g.Group) {
            Write-Host ("  -> {0}" -f $item.FullName)
        }
    }
}

Write-Host ""
Write-Host "---- Suspicious backups / old versions ----"
Write-Host "(Files matching *bak*.ps1, *backup*.ps1, *old*.ps1, *copy*.ps1)" -ForegroundColor Cyan
Write-Host ""

$backupPatterns = @("*bak*.ps1", "*backup*.ps1", "*old*.ps1", "*copy*.ps1")
$backups = @()

foreach ($pattern in $backupPatterns) {
    $backups += Get-ChildItem -Path $projectRoot -Filter $pattern -Recurse -ErrorAction SilentlyContinue
}

if ($backups.Count -eq 0) {
    Write-Host "[OK] No obvious backup/old script files found." -ForegroundColor Green
} else {
    $backups = $backups | Sort-Object FullName -Unique
    foreach ($item in $backups) {
        Write-Host ("[BACKUP?] {0}" -f $item.FullName) -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Scan complete ==="
Write-Host "Review any [MISSING], duplicate, or [BACKUP?] entries above."
Write-Host "You can then manually delete or archive old/confusing scripts."
