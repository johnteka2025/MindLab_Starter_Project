# _PRINT_CANONICAL_PATHS_V2.ps1
# Purpose: Canonical path discovery (READ-ONLY, Frontend + Backend)
# Golden Rules: prove paths, no assumptions, no mutations

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\Projects\MindLab_Starter_Project"
$OUTPUT_FILE = "$PROJECT_ROOT\CANONICAL_PATHS_REPORT.txt"

function Line($text) {
    Add-Content -Path $OUTPUT_FILE -Value $text
}

# Reset report
if (Test-Path $OUTPUT_FILE) {
    Remove-Item $OUTPUT_FILE -Force
}

Line "=== MindLab Canonical Paths Report (Frontend + Backend) ==="
Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Line ""

# ---- Project Root ----
Line "Project Root:"
if (Test-Path $PROJECT_ROOT) {
    Line "  OK  -> $PROJECT_ROOT"
} else {
    Line "  ERROR -> Project root NOT FOUND"
    notepad.exe $OUTPUT_FILE
    exit 1
}

Line ""

# ---- Top-level directories ----
Line "Top-level directories:"
$topDirs = @("frontend", "backend")
foreach ($dir in $topDirs) {
    $full = Join-Path $PROJECT_ROOT $dir
    if (Test-Path $full) {
        Line "  OK  -> $full"
    } else {
        Line "  MISSING -> $full"
    }
}

Line ""

# ---- Frontend critical files ----
Line "Frontend critical files:"
$frontendFiles = @(
    "frontend\package.json",
    "frontend\.env",
    "frontend\.env.local",
    "frontend\vite.config.ts",
    "frontend\src\main.tsx",
    "frontend\src\App.tsx",
    "frontend\src\pages\SolvePuzzle.tsx",
    "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
)

foreach ($rel in $frontendFiles) {
    $full = Join-Path $PROJECT_ROOT $rel
    if (Test-Path $full) {
        Line "  OK  -> $full"
    } else {
        Line "  NOT FOUND -> $full"
    }
}

Line ""

# ---- Backend critical files ----
Line "Backend critical files:"
$backendFiles = @(
    "backend\package.json",
    "backend\.env",
    "backend\.env.local",
    "backend\src\index.ts",
    "backend\src\server.ts",
    "backend\src\app.ts",
    "backend\src\routes",
    "backend\src\controllers"
)

foreach ($rel in $backendFiles) {
    $full = Join-Path $PROJECT_ROOT $rel
    if (Test-Path $full) {
        Line "  OK  -> $full"
    } else {
        Line "  NOT FOUND -> $full"
    }
}

Line ""
Line "=== End of Report ==="

# Open report
notepad.exe $OUTPUT_FILE
