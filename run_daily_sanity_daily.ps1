param(
    [string]$BackendHost = "localhost",
    [int]$BackendPort    = 8085
)

$ErrorActionPreference = "Stop"

# Build base URL
$BaseUrl = "http://{0}:{1}" -f $BackendHost, $BackendPort

Write-Host "=== MindLab Daily endpoints sanity ===" -ForegroundColor Cyan
Write-Host ("Base URL : {0}" -f $BaseUrl) -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# STEP 0 - Check that backend port is reachable
# ---------------------------------------------------------
function Test-BackendPort {
    param(
        [string]$TargetHost,
        [int]$Port,
        [int]$TimeoutSec = 5
    )

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $async = $tcpClient.BeginConnect($TargetHost, $Port, $null, $null)
        $success = $async.AsyncWaitHandle.WaitOne($TimeoutSec * 1000, $false)

        if (-not $success -or -not $tcpClient.Connected) {
            $tcpClient.Close()
            return $false
        }

        $tcpClient.EndConnect($async)
        $tcpClient.Close()
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "[STEP 0] Checking backend TCP port $BackendPort ..." -ForegroundColor Yellow
if (-not (Test-BackendPort -TargetHost $BackendHost -Port $BackendPort -TimeoutSec 5)) {
    Write-Host "Backend on $BaseUrl is NOT reachable." -ForegroundColor Red
    Write-Host ""
    Write-Host "Most likely causes:" -ForegroundColor Red
    Write-Host "  - Backend is not running" -ForegroundColor Red
    Write-Host "  - Or still starting up" -ForegroundColor Red
    Write-Host ""
    Write-Host "Suggested next step:" -ForegroundColor Yellow
    Write-Host "  1) Run:  .\mindlab_daily_start.ps1 -TraceOn" -ForegroundColor Yellow
    Write-Host "  2) Then re-run: .\run_daily_sanity_daily.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[RESULT] Daily sanity: FAILED (backend not reachable)" -ForegroundColor Red
    exit 1
}

Write-Host "Backend port reachable ✅" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# STEP 1 - /daily/status
# ---------------------------------------------------------
try {
    Write-Host "[STEP 1] GET /daily/status ..." -ForegroundColor Yellow
    $status = Invoke-RestMethod -Uri "$BaseUrl/daily/status" -Method GET -TimeoutSec 10
    Write-Host "OK: /daily/status response:" -ForegroundColor Green
    $status | Format-List
}
catch {
    Write-Host "ERROR calling /daily/status: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[RESULT] Daily sanity: FAILED at /daily/status" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ---------------------------------------------------------
# STEP 2 - /daily  (fetch instance)
# ---------------------------------------------------------
try {
    Write-Host "[STEP 2] GET /daily ..." -ForegroundColor Yellow
    $instance = Invoke-RestMethod -Uri "$BaseUrl/daily" -Method GET -TimeoutSec 10
    Write-Host "OK: /daily response summary:" -ForegroundColor Green
    $instance | Format-List
}
catch {
    Write-Host "ERROR calling /daily: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[RESULT] Daily sanity: FAILED at /daily" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ---------------------------------------------------------
# STEP 3 - /daily/answer  (demo payload)
# ---------------------------------------------------------
try {
    Write-Host "[STEP 3] POST /daily/answer (demo answer) ..." -ForegroundColor Yellow

    if (-not $instance.dailyChallengeId -or -not $instance.puzzles -or $instance.puzzles.Count -eq 0) {
        throw "Instance does not contain dailyChallengeId or puzzles – cannot send answer."
    }

    $body = @{
        dailyChallengeId = $instance.dailyChallengeId
        puzzleId         = $instance.puzzles[0].id
        answer           = "demo-answer"
    } | ConvertTo-Json

    $resp = Invoke-RestMethod -Uri "$BaseUrl/daily/answer" -Method POST `
        -ContentType "application/json" -Body $body -TimeoutSec 10

    Write-Host "OK: /daily/answer accepted response:" -ForegroundColor Green
    $resp | Format-List
}
catch {
    Write-Host "ERROR calling /daily/answer: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[RESULT] Daily sanity: FAILED at /daily/answer" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Daily sanity: PASSED (status + instance + answer flow)" -ForegroundColor Green
