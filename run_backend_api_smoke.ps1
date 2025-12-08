# run_backend_api_smoke.ps1
# Simple backend API smoke test for key endpoints

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$backendBaseUrl = "http://localhost:8085"

Write-Host "== Backend API Smoke Test =="

function Test-Endpoint {
    param(
        [string] $Path
    )

    $url = "$backendBaseUrl$Path"
    Write-Host "Testing $url ..." -NoNewline

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    }
    catch {
        Write-Host " FAILED (request error)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $false
    }

    if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
        Write-Host " FAILED (HTTP $($response.StatusCode))" -ForegroundColor Red
        return $false
    }

    # Try to parse as JSON when possible
    try {
        $null = $response.Content | ConvertFrom-Json
        Write-Host " OK (JSON)" -ForegroundColor Green
    }
    catch {
        Write-Host " OK (non-JSON response)" -ForegroundColor Green
    }

    return $true
}

$paths = @(
    "/health",
    "/puzzles",
    "/progress",
    "/daily"
)

$allOk = $true

foreach ($p in $paths) {
    $result = Test-Endpoint -Path $p
    if (-not $result) {
        $allOk = $false
    }
}

if (-not $allOk) {
    Write-Host "`nBackend API smoke test FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "`nBackend API smoke test PASSED." -ForegroundColor Green
exit 0
