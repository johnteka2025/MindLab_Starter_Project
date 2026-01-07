# _PRINT_CANONICAL_PATHS.ps1
# Purpose: Canonical path discovery (READ-ONLY)
# Golden Rules: No guessing, no mutation, full verification

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\Projects\MindLab_Starter_Project"
$OUTPUT_FILE = "$PROJECT_ROOT\CANONICAL_PATHS_REPORT.txt"

function Line($text) {
    Add-Content -Path $OUTPUT_FILE -Value $text
}

# Start fresh
if (Test-Path $OUTPUT_FILE) {
    Remove-Item $OUTPUT_FILE -Force
}

Line "=== MindLab Canonical Paths Report ==="
Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Line ""

# Verify project root
Line "Project Root:"
if (Test-Path $PROJECT_ROOT) {
    Line "  OK  -> $PROJECT_ROOT"
} else {
    Line "  ERROR -> Project root NOT FOUND"
    Line ""
    notepad.exe $OUTPUT_FILE
    exit 1
}

Line ""

# Check top-level directories
$expectedDirs = @("frontend", "backend")
Line "Top-level directories:"
foreach ($dir in $expectedDirs) {
    $full = Join-Path $PROJECT_ROOT $dir
    if (Test-Path $full) {
        Line "  OK  -> $full"
    } else {
        Line "  MISSING -> $full"
    }
}

Line ""

# Verify frontend critical files
Line "Frontend critical files:"
$frontendChecks = @(
    "frontend\package.json",
    "frontend\src\pages\SolvePuzzle.tsx",
    "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
)

foreach ($rel in $frontendChecks) {
    $full = Join-Path $PROJECT_ROOT $rel
    if (Test-Path $full) {
        Line "  OK  -> $full"
    } else {
        Line "  MISSING -> $full"
    }
}

Line ""

# Verify backend directory (no deep inspection)
Line "Backend directory check:"
$backendPath = Join-Path $PROJECT_ROOT "backend"
if (Test-Path $backendPath) {
    Line "  OK  -> $backendPath"
} else {
    Line "  MISSING -> $backendPath"
}

Line ""
Line "=== End of Report ==="

# Open in Notepad
notepad.exe $OUTPUT_FILE
