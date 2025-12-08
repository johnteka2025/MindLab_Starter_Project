param()

$ErrorActionPreference = "Stop"

# ------------------------------------------------
# MindLab quick daily stack (v3 – backend + frontend sanity only)
# ------------------------------------------------
$projectRoot = 'C:\Projects\MindLab_Starter_Project'

Write-Host "=== MindLab quick daily stack (v3 – backend + frontend sanity) ===" -ForegroundColor Cyan
Write-Host "[INFO] Project root : $projectRoot"

if (-not (Test-Path -LiteralPath $projectRoot)) {
    Write-Host "[FATAL] Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

Set-Location $projectRoot

# ------------------------------------------------
# Helper: port check
# ------------------------------------------------
function Test-ServicePort {
    param(
        [int]$Port,
        [string]$Name
    )

    $result = Test-NetConnection -ComputerName 'localhost' -Port $Port -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded) {
        Write-Host "[OK] $Name is reachable on port $Port." -ForegroundColor Green
        return $true
    } else {
        Write-Host "[ERROR] $Name is NOT reachable on port $Port." -ForegroundColor Red
        return $false
    }
}

# ------------------------------------------------
# Helper: HTTP check
# ------------------------------------------------
function Test-HttpEndpoint {
    param(
        [string]$Url,
        [string]$Name
    )

    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        Write-Host "[OK] $Name ($Url) -> HTTP $($resp.StatusCode)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR] $Name ($Url) check failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ------------------------------------------------
# Run checks
# ------------------------------------------------
$stackExit = 0

# 1) Port sanity
if (-not (Test-ServicePort -Port 8085 -Name "Backend API server")) {
    $stackExit = 1
}
if (-not (Test-ServicePort -Port 5177 -Name "Frontend dev server (Vite)")) {
    $stackExit = 1
}

# 2) HTTP endpoints (only if ports are OK)
if ($stackExit -eq 0) {
    Write-Host "[STEP] HTTP endpoint sanity checks..." -ForegroundColor Cyan

    if (-not (Test-HttpEndpoint -Url 'http://localhost:8085/health'   -Name 'Backend /health'))   { $stackExit = 1 }
    if (-not (Test-HttpEndpoint -Url 'http://localhost:8085/puzzles'  -Name 'Backend /puzzles'))  { $stackExit = 1 }
    if (-not (Test-HttpEndpoint -Url 'http://localhost:8085/progress' -Name 'Backend /progress')) { $stackExit = 1 }
    if (-not (Test-HttpEndpoint -Url 'http://localhost:8085/app'      -Name 'Backend /app'))      { $stackExit = 1 }
}

# ------------------------------------------------
# Result + exit
# ------------------------------------------------
if ($stackExit -eq 0) {
    Write-Host "[RESULT] Quick daily stack complete." -ForegroundColor Green
} else {
    Write-Host "[ERROR] Quick daily stack failed with exit code $stackExit." -ForegroundColor Red
    Write-Host "[ERROR] Fix the quick stack before continuing development." -ForegroundColor Red
}

$global:LASTEXITCODE = $stackExit
exit $stackExit
