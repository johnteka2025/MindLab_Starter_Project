param(
    [string] $ProjectRoot = 'C:\Projects\MindLab_Starter_Project'
)

Write-Host '=== MindLab daily status note ===' -ForegroundColor Cyan

# Ensure notes folder exists
$notesDir = Join-Path $ProjectRoot 'notes'
if (-not (Test-Path $notesDir)) {
    Write-Host "[INFO] Creating notes folder at: $notesDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $notesDir | Out-Null
} else {
    Write-Host "[INFO] Notes folder already exists at: $notesDir" -ForegroundColor Green
}

# Build filename with date
$today    = Get-Date -Format 'yyyy-MM-dd'
$fileName = "MindLab_Daily_Status_$today.rtf"
$filePath = Join-Path $notesDir $fileName

Write-Host "[INFO] Writing Word-compatible (RTF) summary to:" -ForegroundColor Cyan
Write-Host "       $filePath" -ForegroundColor Cyan

# RTF content (Word opens this natively)
$rtfContent = @"
{\rtf1\ansi
\b MindLab Daily Status - $today\b0\par
\par
Completed today:\par
\par
- Stabilized the MindLab daily routine script (run_mindlab_daily_routine.ps1 v3) so it no longer uses MyInvocation.Statement.\par
- Confirmed that run_all.ps1 can be called safely from the routine.\par
- Verified that the MindLab backend and frontend work together: /app and /app/daily both load correctly in the browser.\par
- Confirmed that the daily routine can complete even if local PROD sanity health loop fails, with route sanity still running afterwards.\par
\par
Next phases / actions:\par
\par
- Phase 1 (Stability & UX):\par
  * Add clearer success / failure feedback on the Daily Challenge page after submitting an answer.\par
  * Add a small Playwright e2e test that checks the /app/daily flow.\par
\par
- Phase 2 (Game design):\par
  * Finalize XP, Level, and Streak rules for MindLab so the backend /progress endpoint becomes more meaningful.\par
\par
- Phase 3 (Polish):\par
  * Clean up old helper scripts we no longer need and keep only the "daily routine" path plus a small set of dev helpers.\par
}
"@

# Write the file
$rtfContent | Set-Content -Path $filePath -Encoding UTF8

Write-Host "[RESULT] Daily status note written successfully." -ForegroundColor Green
Write-Host "         Open it in Word to review or print." -ForegroundColor Green
