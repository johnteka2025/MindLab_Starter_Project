Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Fix DailyChallenge API import casing" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendDir = Join-Path $projectRoot "frontend"
$dailyDir    = Join-Path $frontendDir "src\daily-challenge"

Write-Host "Project root : $projectRoot"
Write-Host "Frontend dir : $frontendDir"
Write-Host "Daily dir    : $dailyDir"
Write-Host ""

# Show any matching files so we can see what exists
Write-Host "[INFO] Files matching *DailyChallengeApi*.ts* in daily-challenge:" -ForegroundColor Yellow
Get-ChildItem $dailyDir -Filter "*DailyChallengeApi*.ts*" | Format-Table Name, FullName
Write-Host ""

# Helper function to fix a single file
function Fix-ImportCasing {
    param(
        [string] $filePath
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "[WARN] File not found: $filePath" -ForegroundColor Yellow
        return
    }

    Write-Host "[STEP] Fixing imports in: $filePath" -ForegroundColor Yellow

    $content = Get-Content $filePath -Raw
    $updated = $content -replace "\./DailyChallengeApi", "./dailyChallengeApi"

    if ($updated -ne $content) {
        Set-Content -Path $filePath -Value $updated -Encoding UTF8
        Write-Host "[OK] Updated import casing in $filePath" -ForegroundColor Green
    } else {
        Write-Host "[INFO] No './DailyChallengeApi' import found in $filePath (nothing changed)." -ForegroundColor DarkYellow
    }

    # Quick peek at the first 8 lines
    Write-Host "[INFO] First 8 lines after change:" -ForegroundColor Cyan
    Get-Content $filePath -TotalCount 8
    Write-Host ""
}

# 3) Fix the two components that import the API client
$homeCardPath   = Join-Path $dailyDir "DailyChallengeHomeCard.tsx"
$detailPagePath = Join-Path $dailyDir "DailyChallengeDetailPage.tsx"

Fix-ImportCasing -filePath $homeCardPath
Fix-ImportCasing -filePath $detailPagePath

Write-Host ""
Write-Host "[RESULT] Import casing fix script completed." -ForegroundColor Green

# 4) Always go back to project root
Set-Location $projectRoot
Write-Host "Back at project root: $(Get-Location)" -ForegroundColor Cyan
