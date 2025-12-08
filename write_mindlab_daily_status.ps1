[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$notesDir    = Join-Path $projectRoot "Notes"

Write-Host "=== MindLab Daily Status note ===" -ForegroundColor Cyan

if (-not (Test-Path $projectRoot)) {
    Write-Host "[ERROR] Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

# Ensure Notes folder exists
if (-not (Test-Path $notesDir)) {
    New-Item -ItemType Directory -Path $notesDir | Out-Null
    Write-Host "[INFO] Created Notes folder at: $notesDir" -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Notes folder already exists at: $notesDir" -ForegroundColor Green
}

# Build filename with today date
$today    = Get-Date -Format 'yyyy-MM-dd'
$fileName = "MindLab_Daily_Status_$today.rtf"
$filePath = Join-Path $notesDir $fileName

Write-Host "[INFO] Writing Word-compatible (RTF) summary to:" -ForegroundColor Cyan
Write-Host "       $filePath" -ForegroundColor Cyan

# RTF content (very simple RTF that Word can open)
$rtfContent = @"
{\rtf1\ansi
\b MindLab Daily Status - $today\b0\par
\par
Completed today:\par
\par
- Daily MindLab routine script \b(run_mindlab_daily_routine.ps1 v3)\b0 is stable and running without errors.\par
- Route sanity script \b(run_route_sanity.ps1)\b0 confirms backend \health, \puzzles, \progress, and \app endpoints are OK.\par
- Daily UI Playwright smoke test \b(run_daily_ui_test.ps1)\b0 for the /app/daily page is green (heading visible, page loads).\par
- Combined daily start orchestrator \b(run_daily_start.ps1)\b0 runs backend routine + UI smoke in one command.\par
\par
Next phases / actions:\par
\par
Phase 1 (Stability & UX):\par
- Add clearer success / error feedback on the Daily Challenge page after submitting an answer.\par
- Extend Playwright coverage on the /app/daily flow (submit demo answer, verify messages).\par
\par
Phase 2 (Game design rules):\par
- Finalize XP, Level, and Streak rules so the /progress endpoint and UI become more meaningful.\par
- Define how daily puzzles contribute to long-term progression in MindLab.\par
\par
Phase 3 (Polish / cleanup):\par
- Clean up any old helper scripts and keep only the “daily routine” + “daily start” + a small set of dev helpers.\par
- Review logs and tighten error messages to make troubleshooting easier.\par
}
"@

Set-Content -Path $filePath -Value $rtfContent -Encoding UTF8

Write-Host "[RESULT] Daily status note written successfully." -ForegroundColor Green
Write-Host "        Open it from File Explorer or Word to review / print." -ForegroundColor Green
Write-Host "        File: $filePath" -ForegroundColor Yellow
