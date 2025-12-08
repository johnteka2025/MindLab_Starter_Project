# MindLab route sanity script
# Quickly checks key backend/frontend URLs.

$ErrorActionPreference = "Stop"

function Test-Route {
    param(
        [string]$Name,
        [string]$Url,
        [switch]$Optional
    )

    Write-Host "`n[CHECK] $Name : $Url" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        $code = [int]$response.StatusCode
        if ($code -ge 200 -and $code -lt 400) {
            Write-Host "[OK] $Name ($code)" -ForegroundColor Green
        } else {
            if ($Optional) {
                Write-Host "[INFO] Optional route $Name returned non-success status: $code (this is OK if dev UI is not running or /app is not configured here)." -ForegroundColor Yellow
            } else {
                Write-Host "[WARN] $Name returned non-success status: $code" -ForegroundColor Yellow
            }
        }
    }
    catch {
        if ($Optional) {
            Write-Host "[INFO] Optional route $Name check failed (dev server may not be running): $($_.Exception.Message)" -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] $Name check failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "=== MindLab route sanity ===" -ForegroundColor Cyan

# Backend (prod-style) routes on 8085
Test-Route -Name "Backend /health"   -Url "http://localhost:8085/health"
Test-Route -Name "Backend /puzzles"  -Url "http://localhost:8085/puzzles"
Test-Route -Name "Backend /progress" -Url "http://localhost:8085/progress"
Test-Route -Name "Backend /app"      -Url "http://localhost:8085/app"

# Frontend dev server (OPTIONAL, only matters if you are doing UI dev)
Test-Route -Name "Frontend dev /app (5177)" -Url "http://localhost:5177/app" -Optional

Write-Host "`n[RESULT] Route sanity checks complete." -ForegroundColor Green
