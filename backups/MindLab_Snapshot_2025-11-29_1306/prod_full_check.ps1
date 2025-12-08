param(
    [switch]$LogToFile
)

$ErrorActionPreference = "Stop"

Write-Host "============================================="
Write-Host "        PROD FULL CHECK (Render + E2E)       "
Write-Host "============================================="
Write-Host ""

# -------------------------------
# STEP 1 – Run PROD sanity script
# -------------------------------
Write-Host "[STEP 1] Running PROD sanity script (Render endpoints)..." -ForegroundColor Cyan

# Run sanity_prod.ps1 from the project root
& "$PSScriptRoot\sanity_prod.ps1" -LogToFile:$LogToFile
$sanityOk = $?

Write-Host ""
if ($sanityOk) {
    Write-Host "[STEP 1] PROD sanity script completed successfully." -ForegroundColor Green
} else {
    Write-Host "[STEP 1] PROD sanity script reported errors." -ForegroundColor Red
}

# -------------------------------
# STEP 2 – Run PROD Playwright E2E
# -------------------------------
Write-Host ""
Write-Host "[STEP 2] Running PROD Playwright e2e test..." -ForegroundColor Cyan

# Go into frontend
Push-Location "$PSScriptRoot\frontend"

# Sanity check 1 – test file exists
$testFile = "tests\e2e\mindlab-prod.spec.ts"
Write-Host "[SANITY] Checking test file exists: $testFile"
if (-not (Test-Path $testFile)) {
    Write-Host "[ERROR] Test file not found: $testFile" -ForegroundColor Red
    Pop-Location
    Write-Host ""
    Write-Host "===== SUMMARY ====="
    Write-Host "Render sanity : $([string]::Copy((if ($sanityOk) {'PASS'} else {'FAIL'})))"
    Write-Host "PROD e2e test : FAIL (missing test file)"
    exit 1
}

Write-Host "[SANITY] Confirmed test file exists: $testFile" -ForegroundColor Green

# Sanity check 2 – find npx executable explicitly
Write-Host "[SANITY] Locating npx executable..."
try {
    $npxCmd = (Get-Command npx.cmd -ErrorAction Stop).Source
    Write-Host "[SANITY] Using npx at: $npxCmd" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Could not find npx on PATH. Is Node.js / npm installed?" -ForegroundColor Red
    Pop-Location
    Write-Host ""
    Write-Host "===== SUMMARY ====="
    Write-Host "Render sanity : $([string]::Copy((if ($sanityOk) {'PASS'} else {'FAIL'})))"
    Write-Host "PROD e2e test : FAIL (npx not found)"
    exit 1
}

# Build the Playwright command (NO wildcards, only this file)
$pwArgs = @(
    "playwright", "test",
    "tests/e2e/mindlab-prod.spec.ts",
    "--trace=on",
    "--reporter=list"
)

Write-Host "[SANITY] Playwright command to run:" -ForegroundColor Yellow
Write-Host "  `"$npxCmd`" $($pwArgs -join ' ')" -ForegroundColor Yellow
Write-Host ""

# Actually run Playwright
& $npxCmd @pwArgs
$playwrightExit = $LASTEXITCODE

if ($playwrightExit -eq 0) {
    Write-Host "[STEP 2] PROD Playwright tests PASSED." -ForegroundColor Green
} else {
    Write-Host "[STEP 2] PROD Playwright tests FAILED with exit code $playwrightExit." -ForegroundColor Red
}

Pop-Location

# -------------------------------
# FINAL SUMMARY & EXIT CODE
# -------------------------------
Write-Host ""
Write-Host "============= SUMMARY ============="
$renderStatus = if ($sanityOk) { "PASS" } else { "FAIL" }
$e2eStatus    = if ($playwrightExit -eq 0) { "PASS" } else { "FAIL" }

Write-Host "Render sanity : $renderStatus"
Write-Host "PROD e2e test : $e2eStatus"
Write-Host "==================================="
Write-Host ""

if ($renderStatus -eq "PASS" -and $e2eStatus -eq "PASS") {
    Write-Host "PROD FULL CHECK RESULT: PASS ✅" -ForegroundColor Green
    exit 0
} else {
    Write-Host "PROD FULL CHECK RESULT: ISSUES FOUND ❌" -ForegroundColor Red
    exit 1
}
