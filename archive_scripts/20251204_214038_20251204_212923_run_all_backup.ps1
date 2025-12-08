[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# MindLab - FULL LOCAL CHECK
# - Starts backend (8085) in a new window
# - Starts frontend (5177) in a new window
# - Runs LOCAL sanity script (sanity_local.ps1)
# - Runs all Playwright e2e tests, including progress-api.spec.ts
# -----------------------------------------------------------------------------

# Resolve project + frontend directories based on script location
$ProjectRoot = Split-Path -Parent $PSCommandPath
$FrontendDir = Join-Path $ProjectRoot "frontend"

Write-Host "=== MindLab run_all.ps1 ===" -ForegroundColor Cyan
Write-Host "Project root : $ProjectRoot"
Write-Host "Frontend dir : $FrontendDir"
Write-Host ""

# -----------------------------
# STEP 0 – Start backend + frontend
# -----------------------------
Write-Host "[STEP 0] Starting backend (8085) and frontend (5177)..." -ForegroundColor Yellow

# Start backend in a new PowerShell window
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-File", "`"$ProjectRoot\run_backend.ps1`""
) -WindowStyle Minimized

# Start frontend dev server in a new PowerShell window
Start-Process powershell -WorkingDirectory $FrontendDir -ArgumentList @(
    "-NoExit",
    "-Command", "npm install; npm run dev -- --port=5177"
) -WindowStyle Minimized

Write-Host "Waiting 15 seconds for servers to stabilize..." -ForegroundColor DarkYellow
Start-Sleep -Seconds 15

# -----------------------------
# STEP 1 – Quick port sanity
# -----------------------------
Write-Host "[STEP 1] Checking backend & frontend ports..." -ForegroundColor Yellow

$backendCheck  = Test-NetConnection localhost -Port 8085
$frontendCheck = Test-NetConnection localhost -Port 5177

Write-Host "Backend port 8085  TcpTestSucceeded: $($backendCheck.TcpTestSucceeded)"
Write-Host "Frontend port 5177 TcpTestSucceeded: $($frontendCheck.TcpTestSucceeded)"

if (-not $backendCheck.TcpTestSucceeded) {
    Write-Warning "Backend (port 8085) is NOT reachable. Check the backend window (run_backend.ps1) for errors."
}

if (-not $frontendCheck.TcpTestSucceeded) {
    Write-Warning "Frontend (port 5177) is NOT reachable. Check the Vite/dev-server window for errors."
}

Write-Host ""

# -----------------------------
# STEP 2 – Run LOCAL sanity script
# -----------------------------
Write-Host "[STEP 2] Running LOCAL sanity script (sanity_local.ps1)..." -ForegroundColor Yellow

Set-Location $ProjectRoot
.\sanity_local.ps1 -LogToFile

Write-Host ""

# -----------------------------
# STEP 3 – Run Playwright e2e tests (LOCAL + PROD-style)
# -----------------------------
Write-Host "[STEP 3] Running Playwright e2e tests..." -ForegroundColor Yellow

Set-Location $FrontendDir

# Run all core tests, including the new progress-api.spec.ts
npx playwright test `
  tests/e2e/health-and-puzzles.spec.ts `
  tests/e2e/mindlab-basic.spec.ts `
  tests/e2e/puzzles-navigation.spec.ts `
  tests/e2e/mindlab-prod.spec.ts `
  tests/e2e/progress-api.spec.ts `
  --trace=on --reporter=list

Write-Host ""
Write-Host "=== run_all.ps1 complete ===" -ForegroundColor Cyan
