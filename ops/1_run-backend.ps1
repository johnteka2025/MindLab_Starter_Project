[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

# --------------------------------------------------
# Locate backend project folder
# --------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

Info "Locating backend project folder..."

$candidateDirs = @(
    (Join-Path $repoRoot "backend"),
    (Join-Path $repoRoot "server"),
    (Join-Path $repoRoot "api")
)

$backendDir = $null

foreach ($dir in $candidateDirs) {
    if (Test-Path (Join-Path $dir "package.json")) {
        $backendDir = $dir
        break
    }
}

if (-not $backendDir) {
    Info "No backend in standard locations. Searching for a Node project with 'dev' or 'start' script..."
    $pkgFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "package.json" -ErrorAction SilentlyContinue

    foreach ($pkg in $pkgFiles) {
        try {
            $jsonText = Get-Content $pkg.FullName -Raw
            $json = $jsonText | ConvertFrom-Json
            if ($json.scripts -and ($json.scripts.dev -or $json.scripts.start)) {
                $backendDir = Split-Path $pkg.FullName -Parent
                break
            }
        }
        catch {
            # ignore invalid JSON and keep searching
        }
    }
}

if (-not $backendDir) {
    Err "Could not find a backend Node project (package.json with 'dev' or 'start' script). Update 1_run-backend.ps1 to point to the correct folder."
    exit 1
}

Ok "Backend project folder: $backendDir"

# --------------------------------------------------
# Check backend port 8085
# --------------------------------------------------
Info "Checking backend port 8085..."
$backendPortOpen = $false
try {
    $backendPortOpen = Test-NetConnection -ComputerName "localhost" -Port 8085 -InformationLevel Quiet -WarningAction SilentlyContinue
} catch {
    Warn "Could not test port 8085 with Test-NetConnection. Continuing anyway."
}

if ($backendPortOpen) {
    Warn "Port 8085 is already accepting connections. Assuming backend is already running. Not starting another instance."
    exit 0
}

# --------------------------------------------------
# npm install (only if node_modules is missing)
# --------------------------------------------------
$nodeModules = Join-Path $backendDir "node_modules"
if (-not (Test-Path $nodeModules)) {
    Info "node_modules not found. Running 'npm install' in backend folder (one-time setup)..."
    Push-Location $backendDir
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
# Start backend dev server
# --------------------------------------------------
Info "Starting backend dev server in a new PowerShell window..."

$command = "cd `"$backendDir`"; npm run dev"
Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", $command | Out-Null

Ok "Backend start command launched. Check the new PowerShell window for backend logs."
