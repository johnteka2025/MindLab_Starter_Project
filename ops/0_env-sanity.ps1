[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

$overallOk = $true

# --------------------------------------------------
# CHECK 1 — Docker CLI available
# --------------------------------------------------
Info "Checking Docker CLI..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Err "Docker CLI not found. Install/start Docker Desktop."
    $overallOk = $false
} else {
    Ok "Docker CLI found."
}

# --------------------------------------------------
# CHECK 2 — Node.js available
# --------------------------------------------------
Info "Checking Node.js..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Err "Node.js not found. Install Node.js (LTS) from nodejs.org."
    $overallOk = $false
} else {
    $nodeVer = (& node -v)
    Ok "Node.js found. Version: $nodeVer"
}

# --------------------------------------------------
# CHECK 3 — npm available
# --------------------------------------------------
Info "Checking npm..."
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Err "npm not found. It should come with Node.js. Reinstall Node if needed."
    $overallOk = $false
} else {
    $npmVer = (& npm -v)
    Ok "npm found. Version: $npmVer"
}

# --------------------------------------------------
# CHECK 4 — Backend port 8085 free (or already in use)
# --------------------------------------------------
Info "Checking backend port 8085..."
$backendPortOpen = $false
try {
    # Returns $true if something is listening on 8085
    $backendPortOpen = Test-NetConnection -ComputerName "localhost" -Port 8085 -InformationLevel Quiet -WarningAction SilentlyContinue
} catch {
    Warn "Could not test port 8085 with Test-NetConnection (older PowerShell?). Skipping detailed check."
}

if ($backendPortOpen) {
    Warn "Port 8085 is already accepting connections. Backend may already be running (or another app is using it)."
} else {
    Ok "Port 8085 appears free."
}

# --------------------------------------------------
# CHECK 5 — Frontend port 5177 free (or already in use)
# --------------------------------------------------
Info "Checking frontend port 5177..."
$frontendPortOpen = $false
try {
    $frontendPortOpen = Test-NetConnection -ComputerName "localhost" -Port 5177 -InformationLevel Quiet -WarningAction SilentlyContinue
} catch {
    Warn "Could not test port 5177 with Test-NetConnection (older PowerShell?). Skipping detailed check."
}

if ($frontendPortOpen) {
    Warn "Port 5177 is already accepting connections. Frontend may already be running (or another app is using it)."
} else {
    Ok "Port 5177 appears free."
}

# --------------------------------------------------
# CHECK 6 — OpenAPI spec exists (current contract-test spec)
# --------------------------------------------------
Info "Checking for OpenAPI spec..."
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir
$specJson  = Join-Path $repoRoot "tests\openapi.json"

if (Test-Path $specJson) {
    Ok "Found OpenAPI spec: $specJson"
} else {
    Warn "Spec not found at $specJson. (Contract tests will fail until spec exists.)"
}

# --------------------------------------------------
# SUMMARY
# --------------------------------------------------
if ($overallOk) {
    Ok "Environment sanity check PASSED. You are ready to run backend, frontend, and contract tests."
    exit 0
} else {
    Err "Environment sanity check FAILED. Fix the errors above before proceeding."
    exit 1
}
