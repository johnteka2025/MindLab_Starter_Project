[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Daily UI Playwright test (v3) ===" -ForegroundColor Cyan

# Adjust only if your project lives somewhere else
$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"
$specRelativePath = "tests\e2e\mindlab-daily-ui.spec.ts"

# -- Sanity: check folders & spec file --

if (-not (Test-Path $projectRoot)) {
    Write-Host "[ERROR] Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $frontendDir)) {
    Write-Host "[ERROR] Frontend folder not found: $frontendDir" -ForegroundColor Red
    exit 1
}

$specPath = Join-Path $frontendDir $specRelativePath
if (-not (Test-Path $specPath)) {
    Write-Host "[ERROR] Playwright spec not found: $specPath" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Frontend dir : $frontendDir" -ForegroundColor Green
Write-Host "[INFO] Spec file    : $specRelativePath" -ForegroundColor Green

# -- Decide which URL to use for the Daily Challenge page --

$backendDaily = "http://localhost:8085/app/daily"
$viteDaily    = "http://localhost:5177/app/daily"

function Test-UrlOk {
    param(
        [string] $Url
    )
    try {
        $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -Method Get -TimeoutSec 3
        if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

Write-Host "[CHECK] Probing backend /app (8085) at $backendDaily ..." -ForegroundColor Yellow
$backendOk = Test-UrlOk -Url $backendDaily
if ($backendOk) {
    Write-Host "[OK] Backend /app is reachable. Using backend URL for DAILY_UI_URL." -ForegroundColor Green
    $dailyUrl = $backendDaily
}
else {
    Write-Host "[WARN] Backend /app (8085) not reachable. Unable to connect to the remote server" -ForegroundColor Yellow
    Write-Host "[CHECK] Probing Vite dev (5177) at $viteDaily ..." -ForegroundColor Yellow

    $viteOk = Test-UrlOk -Url $viteDaily
    if (-not $viteOk) {
        Write-Host "[ERROR] Could not reach ANY Daily URL. Make sure backend and/or dev server are running." -ForegroundColor Red
        Write-Host "        Tried: $backendDaily and $viteDaily" -ForegroundColor Red
        exit 1
    }

    Write-Host "[OK] Using Vite dev (5177) for DAILY_UI_URL." -ForegroundColor Green
    $dailyUrl = $viteDaily
}

Write-Host "[INFO] DAILY_UI_URL set to: $dailyUrl" -ForegroundColor Cyan
$env:DAILY_UI_URL = $dailyUrl

# -- Run Playwright --

Push-Location $frontendDir
try {
    Write-Host "[INFO] Running: npx playwright test $specRelativePath --trace=on" -ForegroundColor Cyan
    npx playwright test $specRelativePath --trace=on
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -eq 0) {
    Write-Host "[RESULT] Daily UI Playwright test PASSED." -ForegroundColor Green
}
else {
    Write-Host "[RESULT] Daily UI Playwright test FAILED with exit code $exitCode." -ForegroundColor Red
}

exit $exitCode
