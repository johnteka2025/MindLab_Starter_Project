param(
    [string]$BackendUrl  = "http://localhost:8080",
    [string]$FrontendUrl = "http://localhost:4173",
    [int]$MaxTries       = 30,
    [int]$DelaySeconds   = 5
)

Write-Host "========================================="
Write-Host "         PROD SANITY CHECK SCRIPT"
Write-Host "========================================="
Write-Host "Backend URL : $BackendUrl"
Write-Host "Frontend URL: $FrontendUrl"
Write-Host "MaxTries    : $MaxTries"
Write-Host "Delay (sec) : $DelaySeconds"
Write-Host ""

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description
    )

    Write-Host "-----------------------------------------"
    Write-Host "Checking: $Description"
    Write-Host "URL     : $Url"
    Write-Host "-----------------------------------------"

    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "SUCCESS: HTTP $($resp.StatusCode)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FAILED initial check for $Description" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $false
    }
}

function Wait-For-Health {
    param(
        [string]$HealthUrl,
        [int]$MaxTries,
        [int]$DelaySeconds
    )

    Write-Host ""
    Write-Host "Waiting for backend health to be READY..."
    Write-Host "Health URL : $HealthUrl"
    Write-Host "MaxTries   : $MaxTries"
    Write-Host "Delay (sec): $DelaySeconds"
    Write-Host ""

    $isReady = $false

    for ($i = 1; $i -le $MaxTries; $i++) {
        try {
            $resp = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            Write-Host "Try ${i}: /health -> HTTP $($resp.StatusCode)"

            if ($resp.StatusCode -eq 200) {
                # Optionally inspect body content if your API returns structured health
                # Example: expecting JSON with "status":"UP"
                try {
                    $json = $resp.Content | ConvertFrom-Json -ErrorAction Stop
                    if ($json.status -in @("UP","ok","OK","healthy")) {
                        Write-Host "Backend health status is UP." -ForegroundColor Green
                        $isReady = $true
                        break
                    }
                    else {
                        Write-Host "Try ${i}: /health returned HTTP 200 but status is '$($json.status)'." -ForegroundColor Yellow
                    }
                }
                catch {
                    # If response is plain text or not JSON, just accept 200 as good enough
                    Write-Host "Try ${i}: /health HTTP 200 (non-JSON body) – treating as READY." -ForegroundColor Green
                    $isReady = $true
                    break
                }
            }
            else {
                Write-Host "Try ${i}: /health HTTP $($resp.StatusCode) – not ready yet..." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Try ${i}: /health not ready yet..." -ForegroundColor Yellow
        }

        Start-Sleep -Seconds $DelaySeconds
    }

    if (-not $isReady) {
        Write-Host ""
        Write-Host "ERROR: Backend health did not become READY after $MaxTries tries." -ForegroundColor Red
        return $false
    }

    Write-Host ""
    Write-Host "Backend health is READY." -ForegroundColor Green
    return $true
}

# -----------------------------
# MAIN SCRIPT FLOW
# -----------------------------

$overallSuccess = $true

Write-Host ""
Write-Host "STEP 1 — Quick connectivity sanity" -ForegroundColor Cyan

$backendOk  = Test-Endpoint -Url "$BackendUrl/health" -Description "Backend /health"
$frontendOk = Test-Endpoint -Url $FrontendUrl -Description "Frontend root page"

if (-not $backendOk) {
    Write-Host "NOTE: Backend /health initial check failed. Will enter wait loop..." -ForegroundColor Yellow
}

if (-not $frontendOk) {
    Write-Host "WARNING: Frontend initial check failed. This might be OK if it is still starting." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "STEP 2 — Wait for backend /health to be fully READY" -ForegroundColor Cyan

$healthReady = Wait-For-Health -HealthUrl "$BackendUrl/health" -MaxTries $MaxTries -DelaySeconds $DelaySeconds

if (-not $healthReady) {
    $overallSuccess = $false
}

Write-Host ""
Write-Host "STEP 3 — Optional: Check a business endpoint (e.g., /puzzles)" -ForegroundColor Cyan

try {
    $puzzlesUrl = "$BackendUrl/puzzles"
    Write-Host "Checking puzzles endpoint: $puzzlesUrl"
    $puzzlesResp = Invoke-WebRequest -Uri $puzzlesUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "Puzzles endpoint HTTP $($puzzlesResp.StatusCode)" -ForegroundColor Green
}
catch {
    Write-Host "Puzzles endpoint check FAILED (this may be OK if not yet implemented)." -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor DarkYellow
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
