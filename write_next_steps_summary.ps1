# write_next_steps_summary.ps1
# Run next-steps suite and write a daily RTF summary file for Word

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$docsDir     = Join-Path $projectRoot "docs"

if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir | Out-Null
}

$today      = Get-Date -Format "yyyy-MM-dd"
$summaryPath = Join-Path $docsDir ("MindLab_Next_Steps_Status_{0}.rtf" -f $today)

$nextStepsScript = Join-Path $projectRoot "run_next_steps_suite.ps1"

Write-Host "== MindLab Next Steps Daily Summary =="

if (-not (Test-Path $nextStepsScript)) {
    Write-Host "ERROR: run_next_steps_suite.ps1 not found at: $nextStepsScript" -ForegroundColor Red
    exit 1
}

# Run the suite and capture output
Write-Host "[INFO] Running next-steps suite and capturing output..."

$log = & $nextStepsScript | Out-String
$exitCode = $LASTEXITCODE

# Build an RTF-friendly body (plain text with minimal RTF header)
$header = @"
{\rtf1\ansi
{\b MindLab Next Steps Status - $today}\par
\par
"@

$footer = "}"  # closes the RTF document

$bodyLines = $log -split "`r?`n" | ForEach-Object {
    # Escape backslashes and braces for RTF
    $escaped = $_ -replace "\\", "\\\\" -replace "{", "\{" -replace "}", "\}"
    "$escaped\par"
}

$rtfContent = $header + ($bodyLines -join "`r`n") + "`r`n" + $footer

Write-Host "[INFO] Writing summary to: $summaryPath"
$rtfContent | Out-File -FilePath $summaryPath -Encoding ASCII -Force

if ($exitCode -ne 0) {
    Write-Host "Summary written, but next-steps suite FAILED (exit code $exitCode)." -ForegroundColor Yellow
    exit $exitCode
}

Write-Host "Summary written successfully and next-steps suite PASSED." -ForegroundColor Green
Write-Host "You can open this file in Word: $summaryPath"
exit 0
