param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

Write-Host "=== MindLab Daily Environment Check ===" -ForegroundColor Cyan
Write-Host ("Project root : {0}" -f (Get-Location)) -ForegroundColor Cyan
Write-Host ""

# Ensure the main daily script exists
if (-not (Test-Path ".\mindlab_daily_start.ps1")) {
    Write-Host "ERROR: mindlab_daily_start.ps1 not found in project root." -ForegroundColor Red
    Write-Host "[RESULT] Daily environment check: FAILED (missing mindlab_daily_start.ps1)" -ForegroundColor Red
    exit 1
}

Write-Host "STEP 1 – Running mindlab_daily_start.ps1 ..." -ForegroundColor Yellow

# Run the main daily script with or without -TraceOn
$dailyExit = 0
try {
    if ($TraceOn) {
        .\mindlab_daily_start.ps1 -TraceOn
    }
    else {
        .\mindlab_daily_start.ps1
    }
    $dailyExit = $LASTEXITCODE
}
catch {
    Write-Host ("ERROR running mindlab_daily_start.ps1: {0}" -f $_.Exception.Message) -ForegroundColor Red
    $dailyExit = 1
}

Write-Host ""

if ($dailyExit -ne 0) {
    Write-Host ("[RESULT] Daily environment check: FAILED (exit code {0})" -f $dailyExit) -ForegroundColor Red
    Write-Host "Next steps: review the latest daily start log in the logs folder before starting new work." -ForegroundColor Yellow
    exit $dailyExit
}

Write-Host "[RESULT] Daily environment check: PASSED" -ForegroundColor Green
Write-Host "You are clear to begin a new phase or development work." -ForegroundColor Green
exit 0
