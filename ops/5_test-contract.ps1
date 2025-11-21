[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

# --------------------------------------------------
# STEP 0 — Check Docker CLI
# --------------------------------------------------
Info "Checking Docker..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Err "Docker CLI not found. Install/start Docker Desktop."
    exit 1
}
Ok "Docker detected."

# --------------------------------------------------
# STEP 1 — Backend health
# --------------------------------------------------
$health = "http://localhost:8085/api/health"
Info "Checking backend health at $health ..."

try {
    $resp = Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 10
    if ($resp.StatusCode -ne 200) {
        Err "Backend returned HTTP $($resp.StatusCode)"
        exit 1
    }
}
catch {
    Err "Health request failed: $($_.Exception.Message)"
    exit 1
}

Ok "Backend is healthy (200)."

# --------------------------------------------------
# STEP 2 — Find OpenAPI spec (flexible)
# --------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

$defaultSpec = Join-Path $repoRoot "spec\openapi.yml"
$specPath    = $null

if (Test-Path $defaultSpec) {
    $specPath = $defaultSpec
    Ok "Using default OpenAPI spec: $specPath"
}
else {
    Info "Default spec not found at $defaultSpec"
    Info "Searching repo for openapi*.yml/.yaml/.json ..."

    $candidate = Get-ChildItem -Path $repoRoot -Recurse `
        -Include 'openapi*.yml','openapi*.yaml','openapi*.json' `
        -File -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -eq $candidate) {
        Err "Could not find any openapi*.yml/.yaml/.json under $repoRoot"
        Err "If your spec has a different name or location, update `$specPath in this script."
        exit 1
    }

    $specPath = $candidate.FullName
    Ok "Found OpenAPI spec by search: $specPath"
}

# --------------------------------------------------
# STEP 3 — Run Dredd via Docker (correct command)
# --------------------------------------------------
Info "Running Dredd..."

$dockerImage     = "apiaryio/dredd:latest"
$specInContainer = "/tmp/openapi.json"

# Build safe -v argument: "C:\...\openapi.json:/tmp/openapi.yml"
$volumeArg = ("{0}:{1}" -f $specPath, $specInContainer)

$dockerCmd = @(
    "run"
    "--rm"
    "--name", "mindlab-dredd"
    "-v", $volumeArg
    "--network=host"
    $dockerImage
    "dredd"                 # <-- run dredd
    $specInContainer        # <-- spec path inside container
    "http://host.docker.internal:8085"   # <-- backend URL from container
)

Info "Executing Docker command:"
Info "docker $($dockerCmd -join ' ')"

$LASTEXITCODE = 0
& docker @dockerCmd

$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Ok "Contract tests PASSED."
    exit 0
}

Err "Contract tests FAILED. Exit code: $exitCode"
exit $exitCode
