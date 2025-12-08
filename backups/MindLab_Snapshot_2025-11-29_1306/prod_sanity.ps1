param(
    # Default values aimed at your Render PROD deployment
    [string]$BackendUrl  = "https://mindlab-swpk.onrender.com",
    [string]$FrontendUrl = "https://mindlab-swpk.onrender.com/app",
    [int]$MaxTries       = 30,
    [int]$DelaySeconds   = 5,

    # Logging options
    [switch]$LogToFile,
    [string]$LogPath = ".\prod_sanity.log"
)

# ============================================================
#  Logging helpers
# ============================================================

# Make logging options visible inside functions
$script:LogToFile = $LogToFile
$script:LogPath   = $LogPath

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"

    # Console
    if ($Color) {
        Write-Host $line -ForegroundColor $Color
    }
    else {
        Write-Host $line
    }

    # Optional file log
    if ($script:LogToFile) {
        try {
            Add-Content -Path $script:LogPath -Value $line -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "WARN: Failed to write to log file $($script:LogPath): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# ============================================================
#  HTTP Helpers
# ============================================================

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description,
        [int]$TimeoutSec = 20
    )

    Write-Log "Checking [$Description] at $Url" "INFO" Cyan

    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        Write-Log "SUCCESS: $Description -> HTTP $($resp.StatusCode)" "INFO" Green
        return [PSCustomObject]@{
            Ok       = $true
            Status   = $resp.StatusCode
            Content  = $resp.Content
            Response = $resp
        }
    }
    catch {
        Write-Log "FAILED: $Description ($($_.Exception.Message))" "WARN" Yellow
        return [PSCustomObject]@{
            Ok       = $false
            Status   = $null
            Content  = $null
            Response = $null
        }
    }
}

function Wait-For-Health {
    param(
        [string]$HealthUrl,
        [int]$MaxTries,
        [int]$DelaySeconds
    )

    Write-Log "Waiting for backend health to be READY..." "INFO" Cyan
    Write-Log "Health URL : $HealthUrl" "INFO" Gray
    Write-Log "MaxTries   : $MaxTries"   "INFO" Gray
    Write-Log "Delay (sec): $DelaySeconds" "INFO" Gray

    $isReady = $false

    # Accepted "healthy" values from JSON, e.g. { "status": "ok" }
    $healthyStatuses = @("UP", "up", "OK", "ok", "HEALTHY", "healthy", "pass", "PASS")

    for ($i = 1; $i -le $MaxTries; $i++) {
        try {
            $resp = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            Write-Log "Try ${i}: /health -> HTTP $($resp.StatusCode)" "INFO" White

            if ($resp.StatusCode -eq 200) {
                # Attempt to parse JSON, but don't require it
                $statusValue = $null
                try {
                    $json = $resp.Content | ConvertFrom-Json -ErrorAction Stop

                    if ($null -ne $json.status) {
                        $statusValue = [string]$json.status
                        if ($healthyStatuses -contains $statusValue) {
                            Write-Log "Backend health status is '$statusValue'. Treating as READY." "INFO" Green
                            $isReady = $true
                            break
                        }
                        else {
                            Write-Log "Try ${i}: /health HTTP 200 but status is '$statusValue' (not in [$($healthyStatuses -join ', ')])" "WARN" Yellow
                        }
                    }
                    else {
                        Write-Log "Try ${i}: /health JSON has no 'status' field. Accepting HTTP 200 as READY." "INFO" Green
                        $isReady = $true
                        break
                    }
                }
                catch {
                    # Non-JSON /health body: just trust HTTP 200
                    Write-Log "Try ${i}: /health HTTP 200 with non-JSON body. Treating as READY." "INFO" Green
                    $isReady = $true
                    break
                }
            }
            else {
                Write-Log "Try ${i}: /health HTTP $($resp.StatusCode) – not ready yet..." "WARN" Yellow
            }
        }
        catch {
            Write-Log "Try ${i}: /health not ready yet... ($($_.Exception.Message))" "WARN" Yellow
        }

        Start-Sleep -Seconds $DelaySeconds
    }

    if (-not $isReady) {
        Write-Log "Backend health did not become READY after $MaxTries tries." "ERROR" Red
        return $false
    }

    Write-Log "Backend health is READY." "INFO" Green
    return $true
}

# ============================================================
#  MAIN SCRIPT FLOW
# ============================================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "         PROD / ENV SANITY CHECK"        -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Backend URL : $BackendUrl"
Write-Host "Frontend URL: $FrontendUrl"
Write-Host "MaxTries    : $MaxTries"
Write-Host "Delay (sec) : $DelaySeconds"
if ($LogToFile) {
    Write-Host "Log file    : $LogPath"
}
Write-Host ""

$overallSuccess = $true

# STEP 1 — Quick connectivity
Write-Log "STEP 1 — Quick connectivity sanity" "INFO" Cyan

$backendHealthResult = Test-Endpoint -Url "$BackendUrl/health" -Description "Backend /health"
$frontendResult      = Test-Endpoint -Url $FrontendUrl -Description "Frontend page (/app)"

if (-not $backendHealthResult.Ok) {
    Write-Log "NOTE: Backend /health initial check failed. Will still enter wait loop..." "WARN" Yellow
}

if (-not $frontendResult.Ok) {
    Write-Log "WARNING: Frontend initial check failed. This might be OK if it is still starting or a static site." "WARN" Yellow
}

# STEP 2 — Wait for /health to be fully READY
Write-Log "STEP 2 — Wait for backend /health to be fully READY" "INFO" Cyan

$healthReady = Wait-For-Health -HealthUrl "$BackendUrl/health" -MaxTries $MaxTries -DelaySeconds $DelaySeconds
if (-not $healthReady) {
    $overallSuccess = $false
}

# STEP 3 — Business endpoints
Write-Log "STEP 3 — Business endpoints (/puzzles, /progress, /app)" "INFO" Cyan

$businessEndpoints = @(
    @{ Url = "$BackendUrl/puzzles";  Description = "Backend /puzzles"  },
    @{ Url = "$BackendUrl/progress"; Description = "Backend /progress" },
    @{ Url = "$BackendUrl/app";      Description = "Backend /app"      }
)

foreach ($ep in $businessEndpoints) {
    $result = Test-Endpoint -Url $ep.Url -Description $ep.Description
    if (-not $result.Ok) {
        $overallSuccess = $false
    }
}

Write-Host ""
Write-Host "========================================="

if ($overallSuccess) {
    Write-Host "PROD SANITY RESULT: PASS" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "PROD SANITY RESULT: FAIL" -ForegroundColor Red
    exit 1
}
