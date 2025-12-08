# capture_warnings_snapshot.ps1
# Run the MindLab next-steps suite in a child PowerShell process
# and save all WARN: lines to a dated log file.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$docsDir     = Join-Path $projectRoot "docs"
$warningsDir = Join-Path $docsDir "warnings"

if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir | Out-Null
}

if (-not (Test-Path $warningsDir)) {
    New-Item -ItemType Directory -Path $warningsDir | Out-Null
}

$nextStepsScript = Join-Path $projectRoot "run_next_steps_suite.ps1"

Write-Host "== MindLab Warnings Snapshot =="

if (-not (Test-Path $nextStepsScript)) {
    Write-Host "ERROR: run_next_steps_suite.ps1 not found at: $nextStepsScript" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Running next-steps suite in a child PowerShell and capturing output..."

# --- Start child PowerShell process using .NET so we can safely read its output ---

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$nextStepsScript`""
$psi.WorkingDirectory = $projectRoot
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError  = $true
$psi.UseShellExecute        = $false
$psi.CreateNoWindow         = $true

$proc = [System.Diagnostics.Process]::Start($psi)

# Read all output streams as plain text
$stdout = $proc.StandardOutput.ReadToEnd()
$stderr = $proc.StandardError.ReadToEnd()

$proc.WaitForExit()
$suiteExitCode = $proc.ExitCode

# Combine stdout + stderr and split into lines
$allText = $stdout + "`n" + $stderr
$logLines = $allText -split "`r?`n"

if (-not $logLines) {
    $logLines = @()
}

# Filter lines that contain WARN:
$warningLines = $logLines | Where-Object { $_ -match "WARN:" }

$timestamp    = Get-Date -Format "yyyy-MM-dd_HHmmss"
$warningsPath = Join-Path $warningsDir ("MindLab_Warnings_{0}.txt" -f $timestamp)

if ($warningLines -and $warningLines.Count -gt 0) {
    Write-Host "[INFO] Found $($warningLines.Count) WARN line(s). Saving snapshot..."
    $warningLines | Out-File -FilePath $warningsPath -Encoding UTF8 -Force
} else {
    Write-Host "[INFO] No WARN: lines found in this run. Writing an empty snapshot note..."
    "No WARN: lines found in this run." | Out-File -FilePath $warningsPath -Encoding UTF8 -Force
}

Write-Host "[INFO] Warnings snapshot saved to: $warningsPath"

if ($suiteExitCode -ne 0) {
    Write-Host "WARNING: next-steps suite FAILED in child process with exit code $suiteExitCode." -ForegroundColor Yellow
    exit $suiteExitCode
}

Write-Host "Next-steps suite PASSED. Warnings snapshot captured successfully." -ForegroundColor Green
exit 0
