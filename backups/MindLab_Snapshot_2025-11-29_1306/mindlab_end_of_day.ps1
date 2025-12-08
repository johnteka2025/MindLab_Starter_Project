$ErrorActionPreference = "Stop"

function Ensure-AtProjectRoot {
    param(
        [string]$ExpectedRoot = "C:\Projects\MindLab_Starter_Project"
    )
    $current = (Get-Location).ProviderPath
    if ($current -ne $ExpectedRoot) {
        Write-Host "[INFO] Changing location to $ExpectedRoot" -ForegroundColor Cyan
        Set-Location $ExpectedRoot
    }
    Write-Host "[INFO] Current location: $(Get-Location)" -ForegroundColor Green
}

Ensure-AtProjectRoot

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$summaryName = "MindLab_Daily_Summary_{0}.docx" -f $dateStamp
$summaryPath = Join-Path (Get-Location) $summaryName

Write-Host "=== MindLab end-of-day ===" -ForegroundColor Cyan
Write-Host "[INFO] Summary file will be: $summaryPath" -ForegroundColor Cyan

# 1) Final quick daily stack
Write-Host "`n[STEP 1] Final quick daily stack..." -ForegroundColor Cyan
.\run_quick_daily_stack.ps1

# 2) Final route sanity
Write-Host "`n[STEP 2] Final route sanity..." -ForegroundColor Cyan
$routeOutput = & .\run_route_sanity.ps1 | Out-String

# 3) Write summary file (plain text with .docx extension so Word opens it)
Write-Host "`n[STEP 3] Writing daily summary file..." -ForegroundColor Cyan

$content = @()
$content += "MindLab – Daily Summary"
$content += "Date: $dateStamp"
$content += "Generated at: $timeStamp"
$content += ""
$content += "=== Route Sanity Output ==="
$content += $routeOutput

$content | Set-Content -Path $summaryPath -Encoding UTF8

Write-Host "[OK] Daily summary written to:" -ForegroundColor Green
Write-Host "  $summaryPath" -ForegroundColor Green
