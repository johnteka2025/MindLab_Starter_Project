# _PRINT_CANONICAL_PATHS_V3.ps1
# Purpose: Canonical paths + critical files + inventory (READ-ONLY)
# Notes: ASCII-only to avoid copy/paste parsing issues

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\Projects\MindLab_Starter_Project"
$OUTPUT_FILE  = Join-Path $PROJECT_ROOT "CANONICAL_PATHS_REPORT.txt"

function Line([string]$text) {
    Add-Content -Path $OUTPUT_FILE -Value $text
}

function ExistsLine([string]$fullPath) {
    if (Test-Path $fullPath) { Line ("  OK  -> " + $fullPath) }
    else { Line ("  NOT FOUND -> " + $fullPath) }
}

function ListInventory {
    param(
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$RootPath,
        [Parameter(Mandatory=$true)][string[]]$ExcludeDirs
    )

    Line ""
    Line $Title
    Line ("  Root: " + $RootPath)

    if (-not (Test-Path $RootPath)) {
        Line "  NOT FOUND (skipping inventory)"
        return
    }

    $items =
        Get-ChildItem -Path $RootPath -Recurse -Force -ErrorAction Stop |
        Where-Object {
            $p = $_.FullName
            foreach ($ex in $ExcludeDirs) {
                # Exclude if path contains \EXCLUDED\
                if ($p -like ("*\" + $ex + "\*")) { return $false }
            }
            return $true
        } |
        Select-Object -ExpandProperty FullName |
        Sort-Object

    if (-not $items -or $items.Count -eq 0) {
        Line "  (No items found)"
        return
    }

    foreach ($i in $items) {
        Line ("  " + $i)
    }
}

# Reset report
if (Test-Path $OUTPUT_FILE) { Remove-Item $OUTPUT_FILE -Force }

Line "=== MindLab Canonical Paths Report (Critical + Inventory) ==="
Line ("Generated: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Line ""

# Project Root
Line "Project Root:"
if (Test-Path $PROJECT_ROOT) { Line ("  OK  -> " + $PROJECT_ROOT) }
else {
    Line "  ERROR -> Project root NOT FOUND"
    notepad.exe $OUTPUT_FILE
    exit 1
}

# Top-level directories
Line ""
Line "Top-level directories:"
$frontendDir = Join-Path $PROJECT_ROOT "frontend"
$backendDir  = Join-Path $PROJECT_ROOT "backend"
ExistsLine $frontendDir
ExistsLine $backendDir

# Frontend critical files
Line ""
Line "Frontend critical files:"
$frontendCritical = @(
    "frontend\package.json",
    "frontend\.env",
    "frontend\.env.local",
    "frontend\vite.config.ts",
    "frontend\src\main.tsx",
    "frontend\src\App.tsx",
    "frontend\src\pages\SolvePuzzle.tsx",
    "frontend\src\daily-challenge\DailyChallengeDetailPage.tsx"
)
foreach ($rel in $frontendCritical) {
    ExistsLine (Join-Path $PROJECT_ROOT $rel)
}

# Backend critical files
Line ""
Line "Backend critical files:"
$backendCritical = @(
    "backend\package.json",
    "backend\.env",
    "backend\.env.local",
    "backend\src",
    "backend\src\index.ts",
    "backend\src\server.ts",
    "backend\src\app.ts",
    "backend\src\routes",
    "backend\src\controllers"
)
foreach ($rel in $backendCritical) {
    ExistsLine (Join-Path $PROJECT_ROOT $rel)
}

# Inventory (exclude heavy dirs)
$exclude = @("node_modules", ".git", "dist", "build", ".next", "coverage", ".turbo", ".cache")

$frontendSrc = Join-Path $PROJECT_ROOT "frontend\src"
$backendSrc  = Join-Path $PROJECT_ROOT "backend\src"

ListInventory -Title "Frontend Inventory (frontend\src) FULL LIST" -RootPath $frontendSrc -ExcludeDirs $exclude
ListInventory -Title "Backend Inventory (backend\src) FULL LIST"  -RootPath $backendSrc  -ExcludeDirs $exclude

# Top-level config files (non-recursive)
Line ""
Line "Frontend top-level config files (non-recursive):"
if (Test-Path $frontendDir) {
    Get-ChildItem -Path $frontendDir -Force -ErrorAction Stop |
        Where-Object { -not $_.PSIsContainer -and $_.Name -match '(\.env|\.json|\.ts|\.js|\.lock)$' } |
        Sort-Object Name |
        ForEach-Object { Line ("  " + $_.FullName) }
} else {
    Line "  NOT FOUND"
}

Line ""
Line "Backend top-level config files (non-recursive):"
if (Test-Path $backendDir) {
    Get-ChildItem -Path $backendDir -Force -ErrorAction Stop |
        Where-Object { -not $_.PSIsContainer -and $_.Name -match '(\.env|\.json|\.ts|\.js|\.lock)$' } |
        Sort-Object Name |
        ForEach-Object { Line ("  " + $_.FullName) }
} else {
    Line "  NOT FOUND"
}

Line ""
Line "=== End of Report ==="

notepad.exe $OUTPUT_FILE
