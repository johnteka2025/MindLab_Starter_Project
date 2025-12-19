param(
    [switch]$TraceOn
)

function Fix-Path($p) {
    return ($p -replace '\\', '/')
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " LOCAL FULL CHECK (backend + frontend + tests)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------
# STEP 1 – LOCAL SANITY
# -------------------------
Write-Host "[STEP 1] Running LOCAL sanity script..." -ForegroundColor Yellow

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$sanityScript = Join-Path $projectRoot "sanity_local.ps1"

if (-not (Test-Path $sanityScript)) {
    Write-Host "ERROR: sanity_local.ps1 missing at $sanityScript" -ForegroundColor Red
    exit 1
}

& $sanityScript -LogToFile
$sanityExit = $LASTEXITCODE
if ($sanityExit -ne 0) {
    Write-Host "[RESULT] Sanity FAILED." -ForegroundColor Red
    exit $sanityExit
}

Write-Host "[RESULT] Sanity PASSED." -ForegroundColor Green
Write-Host ""

# -------------------------
# STEP 2 – PLAYWRIGHT TESTS
# -------------------------
Write-Host "[STEP 2] Running Playwright tests..." -ForegroundColor Yellow

$frontendDir = "C:\Projects\MindLab_Starter_Project\frontend"
Set-Location $frontendDir

# IMPORTANT: USE ONLY FORWARD SLASHES
$localSpecs = @(
    "tests/e2e/health-and-puzzles.spec.ts",
    "tests/e2e/mindlab-basic.spec.ts",
    "tests/e2e/puzzles-navigation.spec.ts",
    "tests/e2e/mindlab-daily-ui.spec.ts",
    "tests/e2e/mindlab-daily-ui-optional.spec.ts"
)

# Verify files exist
$missing = $localSpecs | Where-Object { -not (Test-Path $_) }
if ($missing.Count -gt 0) {
    Write-Host "ERROR: Missing test files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

# Fix paths to avoid Windows escaping issues
$fixedSpecs = $localSpecs | ForEach-Object { Fix-Path $_ }

# Build Playwright command
$npx = Get-Command npx.cmd | Select-Object -ExpandProperty Source

$pwArgs = @("playwright", "test") + $fixedSpecs + @("--reporter=list")
if ($TraceOn) { $pwArgs += "--trace=on" }

Write-Host "[INFO] Using npx: $npx" -ForegroundColor Cyan
Write-Host "[INFO] Playwright command:" -ForegroundColor Cyan
Write-Host "$npx $($pwArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

# Run tests
& $npx @pwArgs
$pwExit = $LASTEXITCODE

if ($pwExit -ne 0) {
    Write-Host "[RESULT] Playwright FAILED." -ForegroundColor Red
} else {
    Write-Host "[RESULT] Playwright PASSED." -ForegroundColor Green
}

Write-Host ""
Write-Host "============ SUMMARY ============" -ForegroundColor Cyan
Write-Host "Sanity     : $(if ($sanityExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "Playwright : $(if ($pwExit -eq 0) { 'PASS' } else { 'FAIL' })"
Write-Host "=================================" -ForegroundColor Cyan

exit $pwExit
