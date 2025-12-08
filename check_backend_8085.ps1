# check_backend_8085.ps1
# Simple sanity check for all MindLab backend endpoints on port 8085

Write-Host "== Checking MindLab backend on http://localhost:8085 ==" -ForegroundColor Cyan

function Show-Endpoint {
    param(
        [string]$Name,
        [string]$Url
    )

    Write-Host "`n-- $Name : $Url --" -ForegroundColor Yellow

    try {
        $res = Invoke-WebRequest $Url -TimeoutSec 5
        $snippet = $res.Content.Substring(0, [Math]::Min(80, $res.Content.Length))
        $contentType = $res.Headers.'Content-Type'
        Write-Host "Status    :" $res.StatusCode
        Write-Host "Type      :" $contentType
        Write-Host "Snippet   :" $snippet
    }
    catch {
        Write-Host "ERROR     :" $_.Exception.Message -ForegroundColor Red
    }
}

Show-Endpoint "Health"   "http://localhost:8085/health"
Show-Endpoint "Puzzles"  "http://localhost:8085/puzzles"
Show-Endpoint "Progress" "http://localhost:8085/progress"
Show-Endpoint "Daily"    "http://localhost:8085/daily"

Write-Host "`nDone." -ForegroundColor Cyan
