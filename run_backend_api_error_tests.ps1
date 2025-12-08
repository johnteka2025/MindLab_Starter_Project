# run_backend_api_error_tests.ps1
# Backend robustness tests for invalid inputs / error scenarios

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$backendBaseUrl = "http://localhost:8085"

Write-Host "== Backend API Error / Robustness Tests =="

function Test-ErrorScenario {
    param(
        [string] $Label,
        [string] $Path
    )

    $url = "$backendBaseUrl$Path"
    Write-Host "Scenario: $Label" -ForegroundColor Cyan
    Write-Host "  URL: $url"

    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        $code = [int]$resp.StatusCode
    }
    catch {
        # Try to extract status code from the exception if possible
        $ex = $_.Exception
        $code = $null

        if ($ex.Response -and $ex.Response.StatusCode) {
            $code = [int]$ex.Response.StatusCode
        }

        if ($code -eq $null) {
            Write-Host "  ERROR: Request failed with no HTTP status (network or server issue)." -ForegroundColor Red
            Write-Host "         $_" -ForegroundColor Red
            return $false
        }
    }

    Write-Host "  HTTP status: $code"

    if ($code -ge 500) {
        Write-Host "  ERROR: Server returned 5xx for an invalid-input scenario. Should handle gracefully." -ForegroundColor Red
        return $false
    }

    Write-Host "  OK: Backend handled invalid input with non-5xx status." -ForegroundColor Green
    return $true
}

$scenarios = @(
    @{ Label = "Invalid puzzle ID";         Path = "/puzzles/invalid-id-xyz" },
    @{ Label = "Invalid puzzle query param"; Path = "/puzzles?id=###invalid###" },
    @{ Label = "Progress for unknown user"; Path = "/progress?user=unknown-user-123" },
    @{ Label = "Daily for far past date";   Path = "/daily?date=1900-01-01" }
)

$allOk = $true

foreach ($s in $scenarios) {
    $ok = Test-ErrorScenario -Label $s.Label -Path $s.Path
    if (-not $ok) {
        $allOk = $false
    }
    Write-Host ""
}

if (-not $allOk) {
    Write-Host "Backend API error tests FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "Backend API error tests PASSED (no 5xx errors for invalid inputs)." -ForegroundColor Green
exit 0
