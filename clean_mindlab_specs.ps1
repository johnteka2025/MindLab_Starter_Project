# clean_mindlab_specs.ps1
# Safely archive suspected duplicate E2E spec files

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$e2eDir      = Join-Path $projectRoot "frontend\tests\e2e"
$archiveDir  = Join-Path $e2eDir "archive_duplicates"

Write-Host "== Cleaning MindLab E2E Specs =="

if (-not (Test-Path $e2eDir)) {
    Write-Host "ERROR: E2E directory not found: $e2eDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $archiveDir)) {
    Write-Host "Creating archive folder: $archiveDir"
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
}

# Add any known duplicate / legacy spec filenames here
$duplicatePatterns = @(
    "*health-and-puzzles_old*.spec.ts",
    "*health-and-puzzles-copy*.spec.ts",
    "*daily-ui-old*.spec.ts",
    "*progress-ui-old*.spec.ts"
)

$filesToMove = @()

foreach ($pattern in $duplicatePatterns) {
    $match = Get-ChildItem -Path $e2eDir -Filter $pattern -File -ErrorAction SilentlyContinue
    if ($match) {
        $filesToMove += $match
    }
}

if ($filesToMove.Count -eq 0) {
    Write-Host "No duplicate/legacy spec files found matching patterns." -ForegroundColor Green
    exit 0
}

Write-Host "The following files will be moved to archive:" -ForegroundColor Yellow
$filesToMove | ForEach-Object { Write-Host " - $($_.FullName)" }

Write-Host ""
$answer = Read-Host "Type 'YES' to confirm move, anything else to cancel"

if ($answer -ne "YES") {
    Write-Host "Operation cancelled. No files moved." -ForegroundColor Yellow
    exit 0
}

foreach ($file in $filesToMove) {
    $dest = Join-Path $archiveDir $file.Name
    Write-Host "Moving $($file.Name) -> $dest"
    Move-Item -Path $file.FullName -Destination $dest -Force
}

Write-Host "Duplicate spec files archived successfully." -ForegroundColor Green
exit 0
