param(
    [switch]$TraceOn
)

if ($TraceOn) {
    Write-Host "[TRACE] Trace mode ON" -ForegroundColor Yellow
}

# ------------------------------
# Paths
# ------------------------------
$projectRoot   = "C:\Projects\MindLab_Starter_Project"
$backendDir    = Join-Path $projectRoot "backend"
$frontendDir   = Join-Path $projectRoot "frontend"
$dailyDetailTsx = Join-Path $frontendDir "src\daily-challenge\DailyChallengeDetailPage.tsx"

Write-Host ""
Write-Host "=== MindLab Phase 13.7 – Use Daily detail page UI ===" -ForegroundColor Cyan
Write-Host "Project root : $projectRoot" -ForegroundColor Cyan
Set-Location $projectRoot

# ------------------------------
# STEP 0 – Quick sanity: required scripts & files exist
# ------------------------------
Write-Host ""
Write-Host "[STEP 0] Checking required scripts & files..." -ForegroundColor Yellow

if (-not (Test-Path ".\mindlab_daily_routine.ps1")) {
    Write-Host "ERROR: mindlab_daily_routine.ps1 not found in project root." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dailyDetailTsx)) {
    Write-Host "ERROR: DailyChallengeDetailPage.tsx not found at:" -ForegroundColor Red
    Write-Host "       $dailyDetailTsx" -ForegroundColor Red
    exit 1
}

Write-Host "OK: mindlab_daily_routine.ps1 found." -ForegroundColor Green
Write-Host "OK: DailyChallengeDetailPage.tsx found." -ForegroundColor Green

# Show brief info about the detail file
Write-Host ""
Write-Host "[INFO] Daily detail page file info:" -ForegroundColor Cyan
Get-Item $dailyDetailTsx | Format-Table FullName, LastWriteTime, Length

# ------------------------------
# STEP 1 – Run MindLab daily routine (health + /daily* sanity)
# ------------------------------
Write-Host ""
Write-Host "[STEP 1] Running MindLab daily routine..." -ForegroundColor Yellow

.\mindlab_daily_routine.ps1 -TraceOn

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: MindLab daily routine FAILED. Fix this before using the UI." -ForegroundColor Red
    exit 1
}

Write-Host "OK: MindLab daily routine PASSED." -ForegroundColor Green

# ------------------------------
# STEP 2 – Start backend dev server in a new PowerShell window
# ------------------------------
Write-Host ""
Write-Host "[STEP 2] Starting backend dev server (new window)..." -ForegroundColor Yellow
Write-Host "Backend dir: $backendDir" -ForegroundColor Cyan

Start-Process powershell -ArgumentList @"
 -NoExit -Command `
    Set-Location '$backendDir'; `
    Write-Host 'Starting backend dev server on port 8085...' -ForegroundColor Cyan; `
    npm run dev
"@

Write-Host "Backend dev window launched." -ForegroundColor Green

# ------------------------------
# STEP 3 – Start frontend dev server in a new PowerShell window
# ------------------------------
Write-Host ""
Write-Host "[STEP 3] Starting frontend dev server (new window)..." -ForegroundColor Yellow
Write-Host "Frontend dir: $frontendDir" -ForegroundColor Cyan

Start-Process powershell -ArgumentList @"
 -NoExit -Command `
    Set-Location '$frontendDir'; `
    Write-Host 'Starting frontend dev server on port 5177...' -ForegroundColor Cyan; `
    npm start
"@

Write-Host "Frontend dev window launched." -ForegroundColor Green

# ------------------------------
# STEP 4 – Open browser to Daily Challenge pages
# ------------------------------
Write-Host ""
Write-Host "[STEP 4] Opening browser to /app and /app/daily ..." -ForegroundColor Yellow

Start-Process "http://localhost:5177/app/"
Start-Process "http://localhost:5177/app/daily"

Write-Host ""
Write-Host "In the browser, verify:" -ForegroundColor Cyan
Write-Host "  1) /app shows the Daily Challenge home card." -ForegroundColor Cyan
Write-Host "  2) /app/daily shows the detail page (puzzle list + status + answer flow)." -ForegroundColor Cyan

# ------------------------------
# STEP 5 – Final info: where we are
# ------------------------------
Write-Host ""
Write-Host "[RESULT] Phase 13.7: Daily detail UI environment started." -ForegroundColor Green
Write-Host "You can now interact with the Daily Challenge in the browser." -ForegroundColor Green

Write-Host ""
Write-Host "Back at project root:" -ForegroundColor Cyan
Get-Location
