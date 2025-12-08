param(
    [switch]$TraceOn
)

# MindLab - Phase 2: Individual core LOCAL Playwright tests

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 2 - Core LOCAL Playwright specs ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

$frontendDir = Join-Path $root "frontend"
$logDir      = Join-Path $root "logs"

# Ensure logs directory exists
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

# ---------------- Health checks (local backend + frontend) ----------------

Write-Host ""
Write-Host "Checking local backend (8085) and frontend (5177)..." -ForegroundColor Cyan

function Test-LocalEndpoint {
    param(
        [string]$Name,
        [string]$Url
    )

    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        Write-Host ("{0} {1} -> HTTP {2}" -f $Name, $Url, $resp.StatusCode) -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host ("{0} {1} FAILED: {2}" -f $Name, $Url, $_.Exception.Message) -ForegroundColor Red
        return $false
    }
}

$backendOk  = Test-LocalEndpoint -Name "Backend(LOCAL)"  -Url "http://localhost:8085/health"
$frontendOk = Test-LocalEndpoint -Name "Frontend(LOCAL)" -Url "http://localhost:5177/"

if (-not ($backendOk -and $frontendOk)) {
    Write-Host ""
    Write-Host "Phase 2 aborted: local backend or frontend is not healthy. Run your daily start first." -ForegroundColor Red
    exit 1
}

# ---------------- Core LOCAL Playwright specs ----------------
# Use FORWARD SLASHES here (Playwright CLI expects that)
$specs = @(
    "tests/e2e/mindlab-basic.spec.ts",
    "tests/e2e/health-and-puzzles.spec.ts",
    "tests/e2e/puzzles-navigation.spec.ts",
    "tests/e2e/progress-api.spec.ts"
)

function Invoke-Phase2Spec {
    param(
        [string]$SpecPath,
        [ref]$ExitCodeRef
    )

    Write-Host ""
    Write-Host ("Running LOCAL spec: {0}" -f $SpecPath) -ForegroundColor Cyan

    # Convert to Windows-style path just for existence check
    $windowsSpec = $SpecPath -replace '/', '\'
    $fullSpecPath = Join-Path $frontendDir $windowsSpec

    if (-not (Test-Path $fullSpecPath)) {
        Write-Host ("ERROR: Spec file not found: {0}" -f $fullSpecPath) -ForegroundColor Red
        $ExitCodeRef.Value = 1
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safeName  = $SpecPath.Replace("\","_").Replace("/","_").Replace(".","_")
    $logPath   = Join-Path $logDir ("phase2_{0}_{1}.log" -f $safeName, $timestamp)

    Write-Host ("Log: {0}" -f $logPath) -ForegroundColor DarkGray

    Push-Location $frontendDir
    try {
        # IMPORTANT: quote the spec path, keep forward slashes
        npx playwright test "$SpecPath" --trace=on *>&1 |
            Tee-Object -FilePath $logPath

        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
    }
    catch {
        Write-Host ("SPEC ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
        $exitCode = 1
    }
    finally {
        Pop-Location
    }

    $ExitCodeRef.Value = $exitCode

    if ($exitCode -eq 0) {
        Write-Host ("Spec {0} : PASS (exit code 0)" -f $SpecPath) -ForegroundColor Green
    } else {
        Write-Host ("Spec {0} : FAIL (exit code {1})" -f $SpecPath, $exitCode) -ForegroundColor Red
    }
}

$results = @()

foreach ($spec in $specs) {
    [int]$code = 0
    Invoke-Phase2Spec -SpecPath $spec -ExitCodeRef ([ref]$code)

    $results += [PSCustomObject]@{
        Spec     = $spec
        ExitCode = $code
        Status   = if ($code -eq 0) { "PASS" } else { "FAIL" }
    }
}

Write-Host ""
Write-Host "=== Phase 2 - Spec summary ===" -ForegroundColor Cyan

foreach ($r in $results) {
    Write-Host ("{0,-40} : {1} (exit code {2})" -f $r.Spec, $r.Status, $r.ExitCode)
}

$anyFail = $results | Where-Object { $_.ExitCode -ne 0 }
$allPass = -not $anyFail

Write-Host ""

if ($allPass) {
    Write-Host "[RESULT] Phase 2 - Core LOCAL specs: PASSED" -ForegroundColor Green
    Write-Host "All core local flows are green. Next: review coverage for missing flows." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "[RESULT] Phase 2 - Core LOCAL specs: FAILED (some specs failed)" -ForegroundColor Red
    Write-Host "Check the individual spec logs in the logs folder for details." -ForegroundColor Red
    exit 1
}
