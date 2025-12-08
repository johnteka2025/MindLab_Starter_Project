param(
    [switch]$TraceOn
)

# MindLab - Phase 3: API robustness (LOCAL + PROD)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 3 - API robustness (LOCAL + PROD) ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

$frontendDir = Join-Path $root "frontend"
$logDir      = Join-Path $root "logs"

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

# Transcript log for the whole Phase 3 run
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath   = Join-Path $logDir ("phase3_api_{0}.log" -f $timestamp)

try {
    Start-Transcript -Path $logPath -Force | Out-Null
}
catch {
    Write-Host "WARNING: Failed to start transcript logging: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# Helper: test one API endpoint multiple times
# ------------------------------------------------------------------
function Invoke-ApiRobustness {
    param(
        [string]$EnvName,
        [string]$BaseUrl,
        [string]$Path,
        [int]$Attempts,
        [ref]$AllOkRef
    )

    Write-Host ""
    Write-Host ("[{0}] Checking endpoint {1}{2} ({3} attempts)..." -f $EnvName, $BaseUrl, $Path, $Attempts) -ForegroundColor Cyan

    $allOk = $true

    for ($i = 1; $i -le $Attempts; $i++) {
        try {
            $url = "$BaseUrl$Path"
            $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
            $code = $resp.StatusCode

            Write-Host ("[{0}] Attempt {1}: {2} -> HTTP {3}" -f $EnvName, $i, $url, $code) -ForegroundColor Green

            # Try to parse JSON just to confirm shape is valid (no exception = ok)
            try {
                $json = $resp.Content | ConvertFrom-Json
            }
            catch {
                Write-Host ("[{0}] Attempt {1}: WARNING: response is not valid JSON" -f $EnvName, $i) -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host ("[{0}] Attempt {1}: ERROR calling {2}: {3}" -f $EnvName, $i, $Path, $_.Exception.Message) -ForegroundColor Red
            $allOk = $false
        }
    }

    $AllOkRef.Value = $allOk

    if ($allOk) {
        Write-Host ("[{0}] Endpoint {1} passed robustness check." -f $EnvName, $Path) -ForegroundColor Green
    } else {
        Write-Host ("[{0}] Endpoint {1} FAILED robustness check." -f $EnvName, $Path) -ForegroundColor Red
    }
}

# ------------------------------------------------------------------
# Helper: run a single Playwright spec from frontend
# ------------------------------------------------------------------
function Invoke-ProgressSpec {
    param(
        [string]$Name,
        [string]$SpecPath,
        [ref]$ExitCodeRef
    )

    Write-Host ""
    Write-Host ("Running Playwright spec: {0} ({1})" -f $Name, $SpecPath) -ForegroundColor Cyan

    $windowsSpec = $SpecPath -replace '/', '\'
    $fullSpecPath = Join-Path $frontendDir $windowsSpec

    if (-not (Test-Path $fullSpecPath)) {
        Write-Host ("ERROR: Spec file not found: {0}" -f $fullSpecPath) -ForegroundColor Red
        $ExitCodeRef.Value = 1
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safeName  = $SpecPath.Replace("\","_").Replace("/","_").Replace(".","_")
    $specLog   = Join-Path $logDir ("phase3_{0}_{1}.log" -f $safeName, $timestamp)

    Write-Host ("Spec log: {0}" -f $specLog) -ForegroundColor DarkGray

    Push-Location $frontendDir
    try {
        npx playwright test "$SpecPath" --trace=on *>&1 |
            Tee-Object -FilePath $specLog

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
        Write-Host ("{0} : PASS (exit code 0)" -f $Name) -ForegroundColor Green
    } else {
        Write-Host ("{0} : FAIL (exit code {1})" -f $Name, $exitCode) -ForegroundColor Red
    }
}

# ------------------------------------------------------------------
# STEP 0 - Basic health check (local + prod)
# ------------------------------------------------------------------

$localBase = "http://localhost:8085"
$prodBase  = "https://mindlab-swpk.onrender.com"

Write-Host ""
Write-Host "STEP 0 - Quick health checks" -ForegroundColor Cyan

# Local health
$localHealthy = $false
try {
    $hLocal = Invoke-WebRequest -Uri "$localBase/health" -UseBasicParsing -TimeoutSec 10
    Write-Host ("LOCAL /health -> HTTP {0}" -f $hLocal.StatusCode) -ForegroundColor Green
    if ($hLocal.StatusCode -eq 200) { $localHealthy = $true }
}
catch {
    Write-Host ("LOCAL /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

# Prod health
$prodHealthy = $false
try {
    $hProd = Invoke-WebRequest -Uri "$prodBase/health" -UseBasicParsing -TimeoutSec 10
    Write-Host ("PROD /health -> HTTP {0}" -f $hProd.StatusCode) -ForegroundColor Green
    if ($hProd.StatusCode -eq 200) { $prodHealthy = $true }
}
catch {
    Write-Host ("PROD /health FAILED: {0}" -f $_.Exception.Message) -ForegroundColor Red
}

if (-not $localHealthy) {
    Write-Host "Local backend is not healthy. Run mindlab_daily_start.ps1 and retry Phase 3." -ForegroundColor Red
    Stop-Transcript | Out-Null
    exit 1
}

if (-not $prodHealthy) {
    Write-Host "Prod backend is not healthy. Investigate /health before continuing." -ForegroundColor Red
    Stop-Transcript | Out-Null
    exit 1
}

# ------------------------------------------------------------------
# STEP 1 - LOCAL API robustness (/progress, /puzzles)
# ------------------------------------------------------------------

Write-Host ""
Write-Host "STEP 1 - LOCAL API robustness" -ForegroundColor Cyan

[int]$localProgressOk = 0
[int]$localPuzzlesOk  = 0

$flag = $false
Invoke-ApiRobustness -EnvName "LOCAL" -BaseUrl $localBase -Path "/progress" -Attempts 3 -AllOkRef ([ref]$flag)
$localProgressOk = if ($flag) { 1 } else { 0 }

$flag = $false
Invoke-ApiRobustness -EnvName "LOCAL" -BaseUrl $localBase -Path "/puzzles" -Attempts 3 -AllOkRef ([ref]$flag)
$localPuzzlesOk = if ($flag) { 1 } else { 0 }

# ------------------------------------------------------------------
# STEP 2 - PROD API robustness (/progress, /puzzles)
# ------------------------------------------------------------------

Write-Host ""
Write-Host "STEP 2 - PROD API robustness" -ForegroundColor Cyan

[int]$prodProgressOk = 0
[int]$prodPuzzlesOk  = 0

$flag = $false
Invoke-ApiRobustness -EnvName "PROD" -BaseUrl $prodBase -Path "/progress" -Attempts 3 -AllOkRef ([ref]$flag)
$prodProgressOk = if ($flag) { 1 } else { 0 }

$flag = $false
Invoke-ApiRobustness -EnvName "PROD" -BaseUrl $prodBase -Path "/puzzles" -Attempts 3 -AllOkRef ([ref]$flag)
$prodPuzzlesOk = if ($flag) { 1 } else { 0 }

# ------------------------------------------------------------------
# STEP 3 - LOCAL Playwright progress spec
# ------------------------------------------------------------------

[int]$localProgressSpecExit = 0
Invoke-ProgressSpec -Name "LOCAL progress-api.spec.ts" -SpecPath "tests/e2e/progress-api.spec.ts" -ExitCodeRef ([ref]$localProgressSpecExit)

# ------------------------------------------------------------------
# STEP 4 - PROD Playwright progress spec
# ------------------------------------------------------------------

[int]$prodProgressSpecExit = 0
Invoke-ProgressSpec -Name "PROD progress-api-prod.spec.ts" -SpecPath "tests/e2e/progress-api-prod.spec.ts" -ExitCodeRef ([ref]$prodProgressSpecExit)

# ------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------

Write-Host ""
Write-Host "=== Phase 3 - API robustness summary ===" -ForegroundColor Cyan

function StatusText($ok) { if ($ok -eq 1) { "PASS" } else { "FAIL" } }

Write-Host ("LOCAL /progress robustness : {0}" -f (StatusText $localProgressOk))
Write-Host ("LOCAL /puzzles robustness  : {0}" -f (StatusText $localPuzzlesOk))
Write-Host ("PROD  /progress robustness : {0}" -f (StatusText $prodProgressOk))
Write-Host ("PROD  /puzzles robustness  : {0}" -f (StatusText $prodPuzzlesOk))

$localSpecStatus = if ($localProgressSpecExit -eq 0) { "PASS" } else { "FAIL" }
$prodSpecStatus  = if ($prodProgressSpecExit -eq 0) { "PASS" } else { "FAIL" }

Write-Host ("LOCAL Playwright progress spec : {0} (exit code {1})" -f $localSpecStatus, $localProgressSpecExit)
Write-Host ("PROD  Playwright progress spec : {0} (exit code {1})" -f $prodSpecStatus, $prodProgressSpecExit)

$allOk = ($localProgressOk -eq 1 -and
          $localPuzzlesOk  -eq 1 -and
          $prodProgressOk  -eq 1 -and
          $prodPuzzlesOk   -eq 1 -and
          $localProgressSpecExit -eq 0 -and
          $prodProgressSpecExit  -eq 0)

Write-Host ""

if ($allOk) {
    Write-Host "[RESULT] Phase 3 - API robustness: PASSED" -ForegroundColor Green
    try { Stop-Transcript | Out-Null } catch {}
    exit 0
}
else {
    Write-Host "[RESULT] Phase 3 - API robustness: FAILED" -ForegroundColor Red
    Write-Host "Check the Phase 3 transcript and spec logs in the logs folder for details." -ForegroundColor Red
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}
