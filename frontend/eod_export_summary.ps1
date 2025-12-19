$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = "C:\Projects\MindLab_Starter_Project\frontend"
$outDir       = Join-Path $projectRoot "daily_summaries"
$stamp        = Get-Date -Format "yyyyMMdd_HHmm"
$txtPath      = Join-Path $outDir "MindLab_EOD_Summary_$stamp.txt"
$rtfPath      = Join-Path $outDir "MindLab_EOD_Summary_$stamp.rtf"

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Pull key “today” status
$latestBackup = Get-ChildItem -Path (Join-Path $frontendRoot "backups") -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like "fullcheck_*" } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

$latestBackupName = if ($latestBackup) { $latestBackup.Name } else { "NONE_FOUND" }

$lines = @()
$lines += "MindLab — End of Day Summary"
$lines += "Date/Time: $(Get-Date)"
$lines += "Project: $projectRoot"
$lines += ""
$lines += "✅ Completed Today"
$lines += "- Local sanity + Playwright full check (run_all.ps1) verified green."
$lines += "- Game Flow UI test suite verified green."
$lines += "- Fullcheck backup created: $latestBackupName"
$lines += "- Backup verified for key artifacts (run_all.ps1, run_game_flow_ui.ps1, mindlab-game-flow.spec.ts)."
$lines += ""
$lines += "📌 Key Files (front-end)"
$lines += "- $frontendRoot\run_all.ps1"
$lines += "- $frontendRoot\run_game_flow_ui.ps1"
$lines += "- $frontendRoot\backup_fullcheck.ps1"
$lines += "- $frontendRoot\verify_latest_fullcheck_backup.ps1"
$lines += "- $frontendRoot\tests\e2e\mindlab-game-flow.spec.ts"
$lines += ""
$lines += "➡️ Tomorrow Plan"
$lines += "1) Start backend + frontend."
$lines += "2) Run run_all.ps1 (must be green)."
$lines += "3) Run run_ui_suite.ps1 (optional) and run_game_flow_ui.ps1."
$lines += "4) Extend Game Flow spec coverage (Daily → Progress validations)."
$lines += "5) Take fullcheck backup + verify."
$lines += ""
$lines += "Notes:"
$lines += "- If Playwright says 'No tests found', run specs using forward slashes like:"
$lines += "  npx playwright test tests/e2e/mindlab-game-flow.spec.ts --trace=on"
$lines += ""

# Write TXT
$lines | Set-Content -Path $txtPath -Encoding UTF8

# Write minimal RTF (simple + reliable)
$rtfBody = ($lines | ForEach-Object {
  ($_ -replace '\\','\\\\' -replace '{','\{' -replace '}','\}' ) + "\par"
}) -join "`r`n"

$rtf = @"
{\rtf1\ansi\deff0
{\fonttbl{\f0 Calibri;}}
\f0\fs24
$rtfBody
}
"@

$rtf | Set-Content -Path $rtfPath -Encoding ASCII

Write-Host "EOD TXT saved: $txtPath" -ForegroundColor Green
Write-Host "EOD RTF saved: $rtfPath" -ForegroundColor Green
