[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "[RESET] Start @ $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Cyan

$projectRoot = "C:\Projects\MindLab_Starter_Project"
Set-Location $projectRoot

# --- 1) Compose down (if compose file exists) -----------------------------
$composeFile = Join-Path $projectRoot "compose.sanitized.yml"
if (Test-Path $composeFile) {
    Write-Host "[RESET] docker compose down (mindlab) using compose.sanitized.yml" -ForegroundColor Yellow
    docker compose -f $composeFile -p mindlab down --remove-orphans | Out-Host
}
elseif (Test-Path (Join-Path $projectRoot "docker-compose.yml")) {
    $composeFile = Join-Path $projectRoot "docker-compose.yml"
    Write-Host "[RESET] docker compose down (mindlab) using docker-compose.yml" -ForegroundColor Yellow
    docker compose -f $composeFile -p mindlab down --remove-orphans | Out-Host
}
else {
    Write-Warning "[RESET] No compose file found, skipping docker compose down."
}

# --- 2) Remove individual containers (ignore errors if missing) ----------
Write-Host "[RESET] Removing containers mindlab-backend, mindlab-db (if present)..." -ForegroundColor Yellow

$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    # This might print 'No such container'; we deliberately ignore that.
    & docker rm -f mindlab-backend mindlab-db 2>$null | Out-Null
}
finally {
    $ErrorActionPreference = $prevEAP
}

# --- 3) Remove the Postgres volume (ignore errors if missing) ------------
Write-Host "[RESET] Removing volume mindlab-dbdata (if present)..." -ForegroundColor Yellow

$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    & docker volume rm mindlab-dbdata 2>$null | Out-Null
}
finally {
    $ErrorActionPreference = $prevEAP
}

# --- 4) Clear test artifacts ---------------------------------------------
$artifacts = Join-Path $projectRoot "tests\.artifacts"
if (Test-Path $artifacts) {
    Write-Host "[RESET] Removing test artifacts at $artifacts" -ForegroundColor Yellow
    Remove-Item $artifacts -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "[RESET] Done." -ForegroundColor Green
