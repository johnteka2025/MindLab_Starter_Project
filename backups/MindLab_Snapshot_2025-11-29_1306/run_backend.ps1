$ErrorActionPreference = "Stop"

# Project root
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
Set-Location $ProjectRoot

Write-Host "=== MindLab backend local runner (FIXED) ===" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"

# Ensure Node exists
try {
    $nodeVersion = node -v
    Write-Host "Node version: $nodeVersion"
}
catch {
    Write-Host "ERROR: Node.js not found. Install Node or fix PATH." -ForegroundColor Red
    exit 1
}

# Correct backend entry
$entry = ".\backend\src\server.cjs"

if (-not (Test-Path $entry)) {
    Write-Host "ERROR: Backend entry file NOT FOUND: $entry" -ForegroundColor Red
    exit 1
}

Write-Host "Using backend entry: $entry" -ForegroundColor Yellow

# Set PORT=8085 for local
$env:PORT = "8085"
Write-Host "Using PORT=$($env:PORT)" -ForegroundColor Yellow

Write-Host ""
Write-Host "Starting backend: node $entry" -ForegroundColor Cyan
Write-Host ""

node $entry
