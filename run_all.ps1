param()

$ErrorActionPreference = "Stop"

# ------------------------------------------------
# 1. Fixed project root
# ------------------------------------------------
$projectRoot = 'C:\Projects\MindLab_Starter_Project'

Write-Host "=== MindLab daily stack (run_all v2 with port sanity) ===" -ForegroundColor Cyan
Write-Host "[INFO] Using project root: $projectRoot" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $projectRoot)) {
    Write-Host "[FATAL] Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

Set-Location $projectRoot

# ------------------------------------------------
# 2. Helper: quick port check
# ------------------------------------------------
function Test-ServicePort {
    param(
        [int]$Port,
        [string]$Name
    )

    $result = Test-NetConnection -ComputerName 'localhost' -Port $Port -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded) {
        Write-Host "[OK] $Name is reachable on port $Port." -ForegroundColor Green
        return $true
    } else {
        Write-Host "[ERROR] $Name is NOT reachable on port $Port." -ForegroundColor Red
        return $false
    }
}

# ------------------------------------------------
# 3. Port sanity: frontend (5177) + backend (8085)
# ------------------------------------------------
$frontendOk = Test-ServicePort -Port 5177 -Name "Frontend dev server (Vite)"
$backendOk  = Test-ServicePort -Port 8085 -Name "Backend API server"

if (-not $frontendOk) {
    Write-Host ""
    Write-Host "[FATAL] Frontend dev server is not running." -ForegroundColor Red
    Write-Host "        Start it in a new window with:" -ForegroundColor Yellow
    Write-Host "        Set-Location 'C:\Projects\MindLab_Starter_Project\frontend'" -ForegroundColor Yellow
    Write-Host "        npm run dev" -ForegroundColor Yellow
    exit 1
}

if (-not $backendOk) {
    Write-Host ""
    Write-Host "[FATAL] Backend API server is not running (port 8085)." -ForegroundColor Red
    Write-Host "        Start your backend stack before running tests." -ForegroundColor Yellow
    Write-Host "        (Use your normal backend start command.)" -ForegroundColor Yellow
    exit 1
}

# ------------------------------------------------
# 4. Helper to run each step script
# ------------------------------------------------
function Invoke-MindLabStep {
    param(
        [string]$Name,
        [string]$RelativeScriptPath,
        [ref]$ExitCodeVar
    )

    $fullPath = Join-Path $projectRoot $RelativeScriptPath

    Write-Host ""
    Write-Host "------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[STEP] $Name" -ForegroundColor Yellow
    Write-Host "       Script: $fullPath" -ForegroundColor DarkGray
    Write-Host "------------------------------------------------" -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $fullPath)) {
        Write-Host "[ERROR] Script not found: $fullPath" -ForegroundColor Red
        $ExitCodeVar.Value = 1
        return
    }

    & $fullPath
    $ExitCodeVar.Value = $LASTEXITCODE

    if ($ExitCodeVar.Value -eq 0) {
        Write-Host "[OK] $Name PASSED." -ForegroundColor Green
    } else {
        Write-Host "[WARN] $Name finished with exit code $($ExitCodeVar.Value)." -ForegroundColor Yellow
    }
}

# ------------------------------------------------
# 5. Run the three main steps
# ------------------------------------------------
$dailyExit    = 0
$dailyUiExit  = 0
$progressExit = 0

Invoke-MindLabStep -Name "Daily routine (backend + routes)" `
                   -RelativeScriptPath 'run_mindlab_daily_routine.ps1' `
                   -ExitCodeVar ([ref]$dailyExit)

Invoke-MindLabStep -Name "Daily UI Playwright test (/app/daily)" `
                   -RelativeScriptPath 'run_daily_ui_test.ps1' `
                   -ExitCodeVar ([ref]$dailyUiExit)

Invoke-MindLabStep -Name "Progress UI Playwright test (/app/progress)" `
                   -RelativeScriptPath 'run_progress_ui_test.ps1' `
                   -ExitCodeVar ([ref]$progressExit)

# ------------------------------------------------
# 6. Summary and overall exit code
# ------------------------------------------------
Write-Host ""
Write-Host "==================== SUMMARY ====================" -ForegroundColor Cyan
Write-Host ("Daily routine      exit code: {0}" -f $dailyExit)
Write-Host ("Daily UI test      exit code: {0}" -f $dailyUiExit)
Write-Host ("Progress UI test   exit code: {0}" -f $progressExit)

$stackExit = 0
foreach ($code in @($dailyExit, $dailyUiExit, $progressExit)) {
    if ($code -ne 0) { $stackExit = 1 }
}

if ($stackExit -eq 0) {
    Write-Host "=== run_all.ps1 complete (STACK HEALTHY) ===" -ForegroundColor Green
} else {
    Write-Host "=== run_all.ps1 complete (STACK HAD ISSUES – see logs above) ===" -ForegroundColor Yellow
}

$global:LASTEXITCODE = $stackExit
exit $stackExit
