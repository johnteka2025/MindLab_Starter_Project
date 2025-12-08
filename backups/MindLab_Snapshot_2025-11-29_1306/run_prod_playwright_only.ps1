[CmdletBinding()]
param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab PROD Playwright only ===" -ForegroundColor Cyan

# 1) Resolve paths
$ScriptPath  = $PSCommandPath
$ProjectRoot = Split-Path -Parent $ScriptPath
$FrontendDir = Join-Path $ProjectRoot "frontend"

Write-Host "Script path  : $ScriptPath"
Write-Host "Project root : $ProjectRoot"
Write-Host "Frontend dir : $FrontendDir"
Write-Host ""

# 2) Sanity: frontend exists
if (-not (Test-Path $FrontendDir)) {
    Write-Host "ERROR: Frontend directory not found: $FrontendDir" -ForegroundColor Red
    exit 1
}

# 3) Test files: local paths (for Test-Path) + CLI paths (for Playwright)
$testFiles = @(
    @{ Local = "tests\e2e\mindlab-prod.spec.ts";      Cli = "tests/e2e/mindlab-prod.spec.ts"      },
    @{ Local = "tests\e2e\progress-api-prod.spec.ts"; Cli = "tests/e2e/progress-api-prod.spec.ts" }
)

Write-Host "[STEP] Checking required test files..." -ForegroundColor Yellow
foreach ($tf in $testFiles) {
    $fullLocal = Join-Path $FrontendDir $tf.Local
    if (-not (Test-Path $fullLocal)) {
        Write-Host "ERROR: Required test file NOT found: $fullLocal" -ForegroundColor Red
        exit 1
    } else {
        Write-Host ("[OK] Found test file: {0}" -f $tf.Local) -ForegroundColor Green
    }
}
Write-Host ""

# 4) Sanity: npx available
Write-Host "[STEP] Checking that 'npx' is available..." -ForegroundColor Yellow
$npxCmd = Get-Command npx -ErrorAction SilentlyContinue
if (-not $npxCmd) {
    Write-Host "ERROR: 'npx' command not found in PATH. Check Node.js / PATH." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] npx command: $($npxCmd.Source)" -ForegroundColor Green
Write-Host ""

# 5) Build command line string (quoted, forward slashes)
$cmdLine = "npx playwright test"

foreach ($tf in $testFiles) {
    $cmdLine += " `"$($tf.Cli)`""
}

if ($TraceOn) {
    $cmdLine += " --trace=on"
}

$cmdLine += " --reporter=list"

Write-Host "[STEP] Final command line:" -ForegroundColor Yellow
Write-Host "  $cmdLine" -ForegroundColor White
Write-Host ""

# 6) Run via cmd.exe so it behaves like manual typing
try {
    Set-Location $FrontendDir
    & cmd.exe /c $cmdLine
    $exitCode = $LASTEXITCODE
}
catch {
    Write-Host "ERROR: Exception while running Playwright: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

if ($exitCode -eq 0) {
    Write-Host "[RESULT] PROD Playwright test PASSED ✅" -ForegroundColor Green
} else {
    Write-Host "[RESULT] PROD Playwright test FAILED ❌ (exit code $exitCode)" -ForegroundColor Red
}

exit $exitCode
