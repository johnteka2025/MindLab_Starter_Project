param(
    [switch]$SkipRouteSanity  # optional: allow skipping STEP 2
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "=== MindLab daily routine ===" -ForegroundColor Cyan

# Resolve paths relative to this script
$projectRoot = Split-Path -Parent $PSCommandPath
$frontendDir = Join-Path $projectRoot "frontend"

$runAllScript = Join-Path $frontendDir "run_all.ps1"
$routeScript  = Join-Path $projectRoot "run_route_sanity.ps1"
$prodLogPath  = Join-Path $projectRoot "prod_sanity_local.log"

Write-Host "[INFO] Project root : $projectRoot"
Write-Host "[INFO] Frontend dir : $frontendDir"
Write-Host ""

# Helper: run a script safely and show clear errors
function Invoke-SafeScript {
    param(
        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [string[]]$Arguments = @(),
        [switch]$RunInDir
    )

    Write-Host ">>> $Description" -ForegroundColor Cyan
    Write-Host "    Script : $ScriptPath"
    if ($RunInDir) {
        Write-Host "    Dir    : $(Split-Path -Parent $ScriptPath)"
    }

    if (-not (Test-Path $ScriptPath)) {
        Write-Host "[ERROR] Required script not found: $ScriptPath" -ForegroundColor Red
        throw "Missing script: $ScriptPath"
    }

    $oldLocation = Get-Location
    try {
        if ($RunInDir) {
            Set-Location (Split-Path -Parent $ScriptPath)
        }

        & $ScriptPath @Arguments

        Write-Host "[OK] $Description completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] $Description failed." -ForegroundColor Red
        Write-Host "        Error type   : $($_.Exception.GetType().FullName)"
        Write-Host "        Error message: $($_.Exception.Message)"
        if ($_.ScriptStackTrace) {
            Write-Host "        Script stack :" -ForegroundColor DarkYellow
            Write-Host ($_.ScriptStackTrace) -ForegroundColor DarkYellow
        }
        throw
    }
    finally {
        Set-Location $oldLocation
    }

    Write-Host ""
}

$overallFailed = $false

# ======================================
# STEP 1 — Quick daily stack via run_all.ps1
# ======================================
try {
    Invoke-SafeScript `
        -Description "STEP 1: Quick daily stack (backend + frontend + tests) via run_all.ps1" `
        -ScriptPath $runAllScript `
        -RunInDir
}
catch {
    $overallFailed = $true
    Write-Host "[RESULT] STEP 1 FAILED — see error details above." -ForegroundColor Red
}

# Extra: inspect prod_sanity_local.log for PROD SANITY RESULT
if (-not $overallFailed -and (Test-Path $prodLogPath)) {
    try {
        $resultLines = Get-Content $prodLogPath | Select-String "PROD SANITY RESULT"
        if ($resultLines) {
            $lastLine = $resultLines[-1].ToString()
            Write-Host "[INFO] Last PROD sanity line from log: $lastLine"
            if ($lastLine -match "FAIL") {
                Write-Host "[ERROR] PROD sanity log reports FAIL. Treating STEP 1 as failed." -ForegroundColor Red
                $overallFailed = $true
            }
        } else {
            Write-Host "[INFO] No 'PROD SANITY RESULT' line found in prod_sanity_local.log." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[WARN] Could not read prod_sanity_local.log: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
elseif (-not (Test-Path $prodLogPath)) {
    Write-Host "[INFO] prod_sanity_local.log not found; skipping PROD sanity log check." -ForegroundColor Yellow
}

# ======================================
# STEP 2 — Route sanity (optional)
# ======================================
if ($SkipRouteSanity) {
    Write-Host "[INFO] SkipRouteSanity was specified — skipping STEP 2 (route sanity)." -ForegroundColor Yellow
}
elseif (-not $overallFailed) {
    try {
        Invoke-SafeScript `
            -Description "STEP 2: Route sanity check (/health, /puzzles, /progress, /app, /app/daily)" `
            -ScriptPath $routeScript
    }
    catch {
        $overallFailed = $true
        Write-Host "[RESULT] STEP 2 FAILED — see error details above." -ForegroundColor Red
    }
}
else {
    Write-Host "[INFO] Skipping STEP 2 because STEP 1 failed." -ForegroundColor Yellow
}

# ======================================
# FINAL RESULT
# ======================================
if ($overallFailed) {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Red
    Write-Host "[RESULT] MindLab daily routine : FAILED" -ForegroundColor Red
    Write-Host "====================================" -ForegroundColor Red
    exit 1
}
else {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "[RESULT] MindLab daily routine : COMPLETED" -ForegroundColor Green
    Write-Host "You are clear to start new feature or development work." -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    exit 0
}
