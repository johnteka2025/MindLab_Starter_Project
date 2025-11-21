[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ROOT = "C:\Projects\MindLab_Starter_Project"
Set-Location $ROOT

Write-Host "=== Phase A – Compose Reset ===" -ForegroundColor Cyan
Write-Host "[INFO] Project root : $ROOT" -ForegroundColor DarkCyan
Write-Host ""

# 1) Ensure base compose file exists
$base = Join-Path $ROOT "docker-compose.yml"
$san  = Join-Path $ROOT "compose.sanitized.yml"

if (-not (Test-Path $base)) {
    Write-Host "[ERROR] Base docker-compose.yml not found at $base" -ForegroundColor Red
    exit 1
}

# 2) Clean old artifacts
Write-Host "[STEP] Removing old compose artifacts" -ForegroundColor Yellow
if (Test-Path $san) {
    Write-Host "  Removing $san" -ForegroundColor Yellow
    Remove-Item $san -Force
}

$artDir = Join-Path $ROOT "tests\.artifacts"
if (Test-Path $artDir) {
    Get-ChildItem $artDir -Filter "compose_*" -ErrorAction SilentlyContinue | Remove-Item -Force
}

Write-Host "[OK] Old compose artifacts cleaned." -ForegroundColor Green
Write-Host ""

# 3) Rebuild sanitized compose (for now: direct copy of base)
Write-Host "[STEP] Creating fresh compose.sanitized.yml from docker-compose.yml" -ForegroundColor Yellow
Copy-Item $base $san -Force
Write-Host "[OK] Wrote $san" -ForegroundColor Green
Write-Host ""

# 4) Validate with docker compose (no -q so we see real errors)
Write-Host "[CHECK] docker compose -f compose.sanitized.yml config" -ForegroundColor Yellow
$cmdOut = ""
try {
    $cmdOut = docker compose -f compose.sanitized.yml config 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] Compose config succeeded. compose.sanitized.yml is valid." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] docker compose config returned exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "------ Raw docker output (for debugging) ------" -ForegroundColor Yellow
        $cmdOut | Write-Host
        Write-Host "------------------------------------------------" -ForegroundColor Yellow
        exit 2
    }
} catch {
    Write-Host "[ERROR] docker compose config threw an exception." -ForegroundColor Red
    Write-Host "        $_" -ForegroundColor Yellow
    exit 2
}

Write-Host ""
Write-Host "=== Phase A – Compose Reset complete ===" -ForegroundColor Cyan
