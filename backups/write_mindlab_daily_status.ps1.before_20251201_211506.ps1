param(
    [string] $NotesFolderName = "Notes"
)

Write-Host "=== MindLab daily status note ===" -ForegroundColor Cyan

# Determine project root (folder where this script lives)
$root = $PSScriptRoot
if (-not $root) {
    $root = (Get-Location).Path
}

Write-Host "[INFO] Project root : $root" -ForegroundColor Green

Push-Location $root
try {
    # 1) Ensure Notes folder exists
    $notesDir = Join-Path $root $NotesFolderName
    if (-not (Test-Path $notesDir)) {
        Write-Host "[INFO] Creating Notes folder at: $notesDir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $notesDir | Out-Null
    }
    else {
        Write-Host "[INFO] Notes folder already exists at: $notesDir" -ForegroundColor Green
    }

    # 2) Build filename with today's date
    $today    = Get-Date -Format 'yyyy-MM-dd'
    $fileName = "MindLab_Daily_Status_$today.rtf"
    $filePath = Join-Path $notesDir $fileName

    Write-Host "[INFO] Writing Word-compatible (RTF) summary to:" -ForegroundColor Cyan
    Write-Host "       $filePath" -ForegroundColor Cyan

    # 3) RTF content (Word opens this natively)
    $rtfContent = @"
{\rtf1\ansi
\b MindLab Daily Status - $today\b0\par
\par
Completed today:\par
\par
- Daily MindLab routine (backend + frontend health + route sanity) is stable.\par
- Daily UI Playwright test (\i mindlab-daily-ui.spec.ts\i0) is green in both headed and headless mode.\par
- Frontend /app and /app/daily both load correctly via Vite dev on port 5177.\par
- Helper scripts for daily stack and UI test are in place and working.\par
\par
Next phases / actions:\par
\par
Phase 1 (Stability & UX):\par
- Add clearer success / failure feedback on the Daily Challenge page after submitting an answer.\par
- Extend Playwright coverage for the /app/daily flow (success, error, edge cases).\par
\par
Phase 2 (Game design):\par
- Finalize XP, Level, and Streak rules so the /progress endpoint becomes more meaningful.\par
- Design how daily puzzles contribute to long-term progression.\par
\par
Phase 3 (Polish / cleanup):\par
- Clean up any old helper scripts we no longer need and keep only the "daily routine" path plus a small set of dev helpers.\par
- Review logs and tighten error messages for easier troubleshooting.\par
}
"@

    # 4) Write the RTF file
    $rtfContent | Set-Content -Path $filePath -Encoding UTF8

    Write-Host "[RESULT] Daily status note written successfully." -ForegroundColor Green
    Write-Host "         Open it in Word to review or print." -ForegroundColor Green
    Write-Host "         File: $filePath" -ForegroundColor Yellow
}
finally {
    Pop-Location
    Write-Host "Back at project root: $((Get-Location).Path)" -ForegroundColor Cyan
}
