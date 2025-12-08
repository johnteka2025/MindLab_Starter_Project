[CmdletBinding()]
param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab PROD FULL CHECK (Render + Playwright CLI) ===" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# FIXED, ABSOLUTE PATHS
# --------------------------------------------------
$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendDir  = "$projectRoot\frontend"
$sanityScript = "$projectRoot\sanity_prod.ps1"

# Always start from project root
Set-Location $projectRoot

# --------------------------------------------------
# STEP 1 – PROD sanity (Render endpoints)
# --------------------------------------------------
Write-Host "[STEP 1] Running PROD sanity script..." -ForegroundColor Yellow
& $sanityScript -LogToFile
$sanityExit = $LASTEXITCODE

if ($sanityExit -ne 0) {
    Write-Host "[RESULT] PROD sanity FAILED ❌ (exit code $sanityExit)" -ForegroundColor Red
    Write-Host "See .\prod_sanity_prod.log for details."
    exit 1
}

Write-Host "[RESULT] PROD sanity PASSED ✅" -ForegroundColor Green
Write-Host ""


# --------------------------------------------------
# STEP 2 – PROD Playwright tests (direct CLI, no npx)
# --------------------------------------------------
Write-Host "[STEP 2] Running PROD Playwright e2e tests..." -ForegroundColor Yellow
Set-Location $frontendDir

# 2.1 File-system paths (Windows-style) for checks
$fsTestFiles = @(
    "tests\e2e\mindlab-prod.spec.ts",
    "tests\e2e\progress-api-prod.spec.ts"
)

foreach ($tf in $fsTestFiles) {
    if (-not (Test-Path $tf)) {
        throw "ERROR: Required test file not found: $tf (cwd: $frontendDir)"
    }
    Write-Host "[OK] Found test file: $tf" -ForegroundColor Green
}

# 2.2 CLI patterns (forward slashes!) for Playwright filters
$cliTestPatterns = @(
    "tests/e2e/mindlab-prod.spec.ts",
    "tests/e2e/progress-api-prod.spec.ts"
)

# 2.3 Locate Playwright CLI inside node_modules (NO NPX)
$playwrightCmd = Join-Path $frontendDir "node_modules\.bin\playwright.cmd"

if (-not (Test-Path $playwrightCmd)) {
    Write-Host "[INFO] Playwright CLI not found. Installing @playwright/test locally..." -ForegroundColor Yellow
    npm install @playwright/test --save-dev
}

if (-not (Test-Path $playwrightCmd)) {
    throw "ERROR: Playwright CLI still not found at $playwrightCmd even after npm install."
}

Write-Host "[OK] Using Playwright CLI: $playwrightCmd" -ForegroundColor Green

# 2.4 Build argument list
$pwArgs = @("test")
$pwArgs += $cliTestPatterns    # forward-slash patterns for Playwright

if ($TraceOn) {
    $pwArgs += "--trace=on"
}
$pwArgs += "--reporter=list"

Write-Host ""
Write-Host "[INFO] Final Playwright command:" -ForegroundColor Yellow
Write-Host "  $playwrightCmd $($pwArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

# 2.5 Run Playwright
& $playwrightCmd @pwArgs
$playExit = $LASTEXITCODE


# --------------------------------------------------
# FINAL SUMMARY & EXIT CODES
# --------------------------------------------------
Write-Host ""
Write-Host "=========== PROD FULL CHECK SUMMARY ===========" -ForegroundColor Cyan

if ($sanityExit -eq 0) { $sanityResult = "PASS" } else { $sanityResult = "FAIL" }
if ($playExit  -eq 0) { $playResult   = "PASS" } else { $playResult   = "FAIL" }

Write-Host "Render sanity : $sanityResult"
Write-Host "Playwright    : $playResult"

if (($sanityExit -eq 0) -and ($playExit -eq 0)) {
    Write-Host ""
    Write-Host "[RESULT] PROD FULL CHECK PASSED ✅" -ForegroundColor Green
    exit 0
}
else {
    Write-Host ""
    Write-Host "[RESULT] PROD FULL CHECK FAILED ❌" -ForegroundColor Red

    if ($playExit -ne 0) {
        # Prefer the Playwright exit code if it failed
        exit $playExit
    }
    else {
        # Fallback non-zero exit when only sanity failed
        exit 1
    }
}
