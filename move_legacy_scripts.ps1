# move_legacy_scripts.ps1
# Move duplicate / backup / old script copies into an archive folder
# so only canonical scripts in project root are used.

param()
$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Legacy Script Mover ==="

# 1) Project root is where this script lives
$projectRoot = Split-Path -Parent $PSCommandPath
Set-Location $projectRoot

Write-Host "[INFO] Project root : $projectRoot"

# 2) Archive folder for old/duplicate scripts
$archiveDir = Join-Path $projectRoot "archive_scripts"
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Write-Host "[INFO] Created archive folder: $archiveDir"
} else {
    Write-Host "[INFO] Using existing archive folder: $archiveDir"
}

# 3) Canonical scripts that must stay in the project root
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

Write-Host ""
Write-Host "[INFO] Canonical scripts that will NOT be moved:" -ForegroundColor Cyan
$canonicalScripts | ForEach-Object { Write-Host "  - $_" }

# 4) Find all .ps1 files in the project
Write-Host ""
Write-Host "[INFO] Scanning for .ps1 files under project root..." -ForegroundColor Cyan

$allPs1 = Get-ChildItem -Path $projectRoot -Filter '*.ps1' -Recurse

# 5) Decide which scripts to move
$moveList = @()

foreach ($file in $allPs1) {
    $relativePath = $file.FullName.Substring($projectRoot.Length).TrimStart('\')
    $isInRoot     = ($file.DirectoryName -eq $projectRoot)
    $name         = $file.Name

    $isCanonicalName = $canonicalScripts -contains $name

    # Backup-like patterns in the filename
    $isBackupName = $name -like "*bak*.ps1" -or
                    $name -like "*backup*.ps1" -or
                    $name -like "*old*.ps1" -or
                    $name -like "*copy*.ps1"

    $shouldMove = $false

    if ($isInRoot -and $isCanonicalName -and -not $isBackupName) {
        # Canonical script in root -> KEEP
        $shouldMove = $false
    }
    elseif ($isBackupName) {
        # Looks like a backup anywhere -> MOVE
        $shouldMove = $true
    }
    elseif ($isCanonicalName -and -not $isInRoot) {
        # Same name as canonical, but NOT in root -> duplicate -> MOVE
        $shouldMove = $true
    }
    else {
        # Other ps1 files in subfolders are left alone for now
        $shouldMove = $false
    }

    if ($shouldMove) {
        $moveList += $file
    }
}

if ($moveList.Count -eq 0) {
    Write-Host ""
    Write-Host "[INFO] No backup/duplicate scripts found to move." -ForegroundColor Green
    $global:LASTEXITCODE = 0
    exit 0
}

Write-Host ""
Write-Host "[INFO] The following files will be moved to archive_scripts:" -ForegroundColor Yellow
foreach ($file in $moveList) {
    Write-Host ("  - {0}" -f $file.FullName)
}

Write-Host ""
Write-Host "[INFO] Moving files..." -ForegroundColor Cyan

foreach ($file in $moveList) {
    $targetPath = Join-Path $archiveDir $file.Name

    # If same name already exists in archive, add timestamp
    if (Test-Path $targetPath) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $targetPath = Join-Path $archiveDir ("{0}_{1}" -f $stamp, $file.Name)
    }

    Move-Item -LiteralPath $file.FullName -Destination $targetPath
    Write-Host ("[MOVED] {0} -> {1}" -f $file.FullName, $targetPath)
}

Write-Host ""
Write-Host "[RESULT] Legacy/backup scripts moved to: $archiveDir" -ForegroundColor Green
Write-Host "         Review them there and delete if you no longer need them."

$global:LASTEXITCODE = 0
exit 0
