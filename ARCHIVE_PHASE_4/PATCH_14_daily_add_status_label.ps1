# C:\Projects\MindLab_Starter_Project\PATCH_14_daily_add_status_label.ps1
# Step 3.4A(1): Add status label on Daily page.
# Golden Rules: absolute paths, backups, sanity build, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$dailyFile    = Join-Path $frontendRoot "src\daily-challenge\DailyChallengeDetailPage.tsx"

function Assert-PathExists([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing required path: $p" }
}

try {
  Assert-PathExists $projectRoot
  Assert-PathExists $frontendRoot
  Assert-PathExists $dailyFile

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $dailyFile ($dailyFile + ".bak_status_" + $ts) -Force
  Write-Host "Backup created: $($dailyFile).bak_status_$ts" -ForegroundColor Green

  # Read current file (we keep your banner code) and inject a status label block.
  $src = Get-Content $dailyFile -Raw

  if ($src -notmatch "const isComplete") { throw "Unexpected file content: could not find 'const isComplete' marker." }

  # Insert status computation after isComplete
  $src = $src -replace "const isComplete = total > 0 && solved === total;\s*",
@'
const isComplete = total > 0 && solved === total;

  const statusText =
    total <= 0 ? "Status: Unknown" :
    solved <= 0 ? "Status: Not started" :
    solved < total ? "Status: In progress" :
    "Status: Complete";
'@

  # Add statusText display under Progress line (only once)
  if ($src -notmatch "data-testid=""daily-status""") {
    $src = $src -replace "(<p style=\{\{ marginTop: 0 \}\}>\s*Progress:\s*<strong>\{solved\}</strong>\s*/\s*<strong>\{total\}</strong>\s*</p>)",
'$1

          <p data-testid="daily-status" style={{ marginTop: 0 }}>
            {statusText}
          </p>'
  }

  Set-Content -Path $dailyFile -Value $src -Encoding UTF8
  Write-Host "Updated file: $dailyFile" -ForegroundColor Green

  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH_14 GREEN: Daily status label added." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
