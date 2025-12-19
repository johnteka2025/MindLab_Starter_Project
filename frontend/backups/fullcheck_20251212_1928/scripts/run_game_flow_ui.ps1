param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " MindLab Game Flow UI - Playwright Run" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure we are in the frontend directory
$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"
Set-Location $frontendDir

# Path to the game-flow spec
$specPath = "tests/e2e/mindlab-game-flow.spec.ts"

if (-not (Test-Path $specPath)) {
    Write-Host "[ERROR] Spec file not found: $specPath" -ForegroundColor Red
    exit 1
}

# Locate npx.cmd
$npxCmd = Get-Command npx.cmd -ErrorAction SilentlyContinue
if (-not $npxCmd) {
    Write-Host "[ERROR] Could not find npx.cmd on PATH. Is Node.js installed?" -ForegroundColor Red
    exit 1
}

$npxExe = $npxCmd.Source

# Build Playwright arguments as an array (no tricky quoting)
$pwArgs = @("playwright", "test", $specPath, "--reporter=list")
if ($TraceOn) {
    $pwArgs += "--trace=on"
}

Write-Host "[INFO] Using npx: $npxExe" -ForegroundColor DarkCyan
Write-Host ("[INFO] Running: npx " + ($pwArgs -join " ")) -ForegroundColor DarkCyan
Write-Host ""

# Run Playwright via npx
& $npxExe $pwArgs
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Host ""
    Write-Host "[RESULT] MindLab Game Flow UI test FAILED (exit code $exitCode)." -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    exit $exitCode
}

Write-Host ""
Write-Host "[RESULT] MindLab Game Flow UI test PASSED." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

exit 0
