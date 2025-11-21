[CmdletBinding()]
param(
    [switch]$FixEnv    # optional: clear BAD proxy/DOCKER_HOST vars at all scopes
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ROOT = "C:\Projects\MindLab_Starter_Project"
Set-Location $ROOT

Write-Host "=== Phase A – Env Doctor ===" -ForegroundColor Cyan
Write-Host "[INFO] Project root  : $ROOT" -ForegroundColor DarkCyan
Write-Host ""

# 1) Docker CLI present?
Write-Host "[CHECK] docker --version" -ForegroundColor Yellow
try {
    $dockerVersion = (docker --version) 2>&1
    Write-Host "[OK] $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] docker CLI not available. Install / repair Docker Desktop." -ForegroundColor Red
    Write-Host "        Hint: winget install --id Docker.DockerDesktop" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 2) Compose v2 plugin (docker compose) present?
Write-Host "[CHECK] docker compose version" -ForegroundColor Yellow
$composeV2 = $null
try {
    $composeV2 = (docker compose version) 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $composeV2" -ForegroundColor Green
    } else {
        Write-Host "[WARN] docker compose plugin not working correctly." -ForegroundColor Yellow
        Write-Host "       Output: $composeV2" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] docker compose plugin not available." -ForegroundColor Yellow
}
Write-Host ""

# 3) Legacy docker-compose.exe on PATH?
Write-Host "[CHECK] legacy docker-compose.exe" -ForegroundColor Yellow
$legacy = Get-Command docker-compose -ErrorAction SilentlyContinue
if ($legacy) {
    Write-Host "[WARN] Legacy docker-compose.exe found at: $($legacy.Source)" -ForegroundColor Yellow
    Write-Host "       This old binary can cause 'invalid proto' and other errors." -ForegroundColor Yellow
    Write-Host "       Recommended:" -ForegroundColor Yellow
    Write-Host "         - Remove it from PATH, or" -ForegroundColor Yellow
    Write-Host "         - Uninstall old Docker Toolbox / older Docker installs" -ForegroundColor Yellow
} else {
    Write-Host "[OK] No legacy docker-compose.exe found on PATH." -ForegroundColor Green
}
Write-Host ""

# 4) Check Docker daemon / info
Write-Host "[CHECK] docker info (daemon healthy?)" -ForegroundColor Yellow
try {
    docker info --format '{{.ServerVersion}}' | Out-Null
    Write-Host "[OK] Docker daemon reachable." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker daemon not reachable. Start Docker Desktop and retry." -ForegroundColor Red
    exit 1
}
Write-Host ""

# 5) Check proxy / DOCKER_HOST environment values at all scopes
Write-Host "[CHECK] Proxy / DOCKER_HOST env vars" -ForegroundColor Yellow

$keys = "HTTP_PROXY","HTTPS_PROXY","ALL_PROXY","NO_PROXY",
        "http_proxy","https_proxy","all_proxy","no_proxy",
        "DOCKER_HOST"

$bad = @()

function ShowVar([string]$name,[string]$scope,[string]$value,[string]$status) {
    $color = "White"
    switch ($status) {
        "BAD" { $color = "Red" }
        "OK"  { $color = "Green" }
        "INF" { $color = "Yellow" }
    }
    Write-Host ("  {0} ({1}) = {2} [{3}]" -f $name,$scope,$value,$status) -ForegroundColor $color
}

foreach ($k in $keys) {
    foreach ($scope in "Process","User","Machine") {
        $v = [Environment]::GetEnvironmentVariable($k,$scope)
        if (-not $v) { continue }

        if ($k -match "PROXY|DOCKER_HOST") {
            if ($v -notmatch "^[a-zA-Z]+://") {
                ShowVar $k $scope $v "BAD"
                $bad += @{Name=$k; Scope=$scope; Value=$v}
            } else {
                ShowVar $k $scope $v "OK"
            }
        } else {
            ShowVar $k $scope $v "INF"
        }
    }
}

if ($bad.Count -eq 0) {
    Write-Host "[OK] No malformed proxy/DOCKER_HOST vars found." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[WARN] Malformed vars (missing scheme like http:// or tcp://):" -ForegroundColor Yellow
    foreach ($b in $bad) {
        Write-Host ("  {0} ({1}) = {2}" -f $b.Name,$b.Scope,$b.Value) -ForegroundColor Yellow
    }

    if ($FixEnv) {
        Write-Host ""
        Write-Host "[FIX] Clearing malformed vars at all scopes..." -ForegroundColor Cyan
        foreach ($b in $bad) {
            [Environment]::SetEnvironmentVariable($b.Name,$null,$b.Scope)
            Write-Host ("  Cleared {0} at {1} scope" -f $b.Name,$b.Scope) -ForegroundColor Green
        }
        Write-Host "[INFO] Close this window, restart Docker Desktop (if open), and open a fresh PowerShell." -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "Run again with -FixEnv to clear the malformed vars automatically." -ForegroundColor Cyan
    }
}
Write-Host ""
Write-Host "=== Phase A – Env Doctor complete ===" -ForegroundColor Cyan
