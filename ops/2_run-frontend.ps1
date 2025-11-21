[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

# --------------------------------------------------
# Locate frontend project folder
# --------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

Info "Locating frontend project folder..."

$candidateDirs = @(
    (Join-Path $repoRoot "frontend"),
    (Join-Path $repoRoot "client"),
    (Join-Path $repoRoot "web"),
    (Join-Path $repoRoot "app")
)

$frontendDir = $null

foreach ($dir in $candidateDirs) {
    if (Test-Path (Join-Path $dir "package.json")) {
        $frontendDir = $dir
        break
    }
}

if (-not $frontendDir) {
    Err "Could not find a frontend Node project (expected package.json in 'frontend', 'client', 'web', or 'app'). Update 2_run-frontend.ps1 to point to the correct folder."
    exit 1
}

Ok "Frontend project folder: $frontendDir"

# --------------------------------------------------
# Optional: check backend health before starting frontend
# --------------------------------------------------
$healthUrl = "http://localhost:8085/api/health"
Info "Checking backend health at $healthUrl ..."
try {
    $resp = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 5
    if ($resp.StatusCode -eq 200) {
        Ok "Backend is healthy (200)."
    } else {
        Warn "Backend responded with HTTP $($resp.StatusCode). Frontend may not work correctly until backend is healthy."
    }
}
catch {
    Warn "Backend health check failed: $($_.Exception.Message). You can still start the frontend, but API calls may fail."
}

# --------------------------------------------------
# Check frontend port 5177
# --------------------------------------------------
Info "Checking frontend port 5177..."
$frontendPortOpen = $false
try {
    $frontendPortOpen = Test-NetConnection -ComputerName "localhost" -Port 5177 -InformationLevel Quiet -WarningAction SilentlyContinue
} catch {
    Warn "Could not test port 5177 with Test-NetConnection. Continuing anyway."
}

if ($frontendPortOpen) {
    Warn "Port 5177 is already accepting connections. Assuming frontend is already running. Not starting another instance."
    exit 0
}

# --------------------------------------------------
# npm install (only if node_modules missing)
# --------------------------------------------------
$nodeModules = Join-Path $frontendDir "node_modules"
if (-not (Test-Path $nodeModules)) {
    Info "node_modules not found. Running 'npm install' in frontend folder (one-time setup)..."
    Push-Location $frontendDir
    try {
        npm install
        if ($LASTEXITCODE -eq 0) {
            Ok "'npm install' completed successfully."
        } else {
            Err "'npm install' failed with exit code $LASTEXITCODE."
            Pop-Location
            exit $LASTEXITCODE
        }
    }
    catch {
        Err "'npm install' threw an exception: $($_.Exception.Message)"
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Ok "node_modules folder exists. Skipping 'npm install'."
}

# --------------------------------------------------
# Start frontend dev server
# --------------------------------------------------
Info "Starting frontend dev server in a new PowerShell window..."

$command = "cd `"$frontendDir`"; npm run dev"
Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", $command | Out-Null

Ok "Frontend start command launched. Check the new PowerShell window for frontend logs (usually on http://localhost:5177)."
