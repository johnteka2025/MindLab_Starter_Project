[CmdletBinding()]
param(
    [switch]$SkipContract,
    [switch]$SkipSmoke
)

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

# --------------------------------------------------
# Locate script directory and repo root
# --------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

Set-Location $repoRoot

Info "Repo root: $repoRoot"

$envScript      = Join-Path $scriptDir "0_env-sanity.ps1"
$backendScript  = Join-Path $scriptDir "1_run-backend.ps1"
$frontendScript = Join-Path $scriptDir "2_run-frontend.ps1"
$smokeScript    = Join-Path $scriptDir "3_smoke-e2e.ps1"
$contractScript = Join-Path $scriptDir "5_test-contract.ps1"

# --------------------------------------------------
# Check that required scripts exist
# --------------------------------------------------
$required = @($envScript, $backendScript, $frontendScript)
foreach ($s in $required) {
    if (-not (Test-Path $s)) {
        Err "Required script not found: $s"
        exit 1
    }
}

# --------------------------------------------------
# STEP 0 — Environment sanity
# --------------------------------------------------
Info "Running environment sanity check (0_env-sanity.ps1)..."

& $envScript
if ($LASTEXITCODE -ne 0) {
    Err "Environment sanity check failed. Aborting run-all."
    exit $LASTEXITCODE
}

Ok "Environment sanity check passed."

# --------------------------------------------------
# STEP 1 — Start backend
# --------------------------------------------------
Info "Starting backend (1_run-backend.ps1)..."

& $backendScript
if ($LASTEXITCODE -ne 0) {
    Err "Backend start script returned exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Ok "Backend start script completed (backend should now be starting or already running)."

# Give backend a moment to come up
Start-Sleep -Seconds 3

# --------------------------------------------------
# STEP 2 — Start frontend
# --------------------------------------------------
Info "Starting frontend (2_run-frontend.ps1)..."

& $frontendScript
if ($LASTEXITCODE -ne 0) {
    Err "Frontend start script returned exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Ok "Frontend start script completed (frontend dev server should now be running)."

# --------------------------------------------------
# STEP 3 — Contract tests (optional)
# --------------------------------------------------
if (-not $SkipContract) {
    if (Test-Path $contractScript) {
        Info "Running contract tests (5_test-contract.ps1)..."
        & $contractScript
        if ($LASTEXITCODE -ne 0) {
            Err "Contract tests FAILED (exit code $LASTEXITCODE)."
            exit $LASTEXITCODE
        } else {
            Ok "Contract tests PASSED."
        }
    } else {
        Warn "Contract test script not found at $contractScript. Skipping contract tests."
    }
} else {
    Warn "Skipping contract tests because -SkipContract was specified."
}

# --------------------------------------------------
# STEP 4 — End-to-end smoke test (optional)
# --------------------------------------------------
if (-not $SkipSmoke) {
    if (Test-Path $smokeScript) {
        Info "Running end-to-end smoke test (3_smoke-e2e.ps1)..."
        & $smokeScript
        if ($LASTEXITCODE -ne 0) {
            Err "End-to-end smoke test FAILED (exit code $LASTEXITCODE)."
            exit $LASTEXITCODE
        } else {
            Ok "End-to-end smoke test PASSED."
        }
    } else {
        Warn "Smoke test script not found at $smokeScript. Skipping smoke test."
    }
} else {
    Warn "Skipping smoke test because -SkipSmoke was specified."
}

# --------------------------------------------------
# DONE
# --------------------------------------------------
Ok "run-all completed successfully. Backend and frontend should be running in their own windows."
exit 0
