# run_morning_frontend_sanity.ps1
# Daily quick check for MindLab backend + Daily UI tests

param()

$ErrorActionPreference = "Stop"

Write-Host "== MindLab Morning Frontend Sanity Check ==" -ForegroundColor Cyan
Write-Host "Project root: C:\Projects\MindLab_Starter_Project" -ForegroundColor DarkCyan

# 1) Ensure we are in the correct folder
Set-Location "C:\Projects\MindLab_Starter_Project"

# 2) Check backend on port 8085
if (Test-Path ".\check_backend_8085.ps1") {
    Write-Host "`n[STEP 1] Checking backend on http://localhost:8085 ..." -ForegroundColor Yellow
    .\check_backend_8085.ps1
} else {
    Write-Warning "check_backend_8085.ps1 not found – skipping backend check."
}

# 3) Run the full Daily UI suite
if (Test-Path ".\run_ui_suite.ps1") {
    Write-Host "`n[STEP 2] Running Daily UI Playwright suite ..." -ForegroundColor Yellow
    .\run_ui_suite.ps1
} else {
    Write-Warning "run_ui_suite.ps1 not found – cannot run Daily UI tests."
}

Write-Host "`n== Morning sanity check finished ==" -ForegroundColor Cyan
