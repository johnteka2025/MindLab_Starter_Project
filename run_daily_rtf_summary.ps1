# run_daily_rtf_summary.ps1
# Create an end-of-day RTF summary from the latest daily stack log

param()
$ErrorActionPreference = "Stop"

# 1. Resolve project + folders
$projectRoot = Split-Path -Parent $PSCommandPath
$reportsDir  = Join-Path $projectRoot "reports"
$logsDir     = Join-Path $reportsDir "logs"

Write-Host "=== MindLab daily RTF summary ==="
Write-Host "[INFO] Project root : $projectRoot"
Write-Host "[INFO] Reports dir  : $reportsDir"
Write-Host "[INFO] Logs dir     : $logsDir"
Write-Host ""

# Sanity: logs directory
if (-not (Test-Path $logsDir)) {
    Write-Host "[ERROR] Logs directory does not exist: $logsDir"
    Write-Host "        Run run_daily_with_error_log.ps1 first."
    $global:LASTEXITCODE = 1
    exit $global:LASTEXITCODE
}

# 2. Find the most recent daily stack log
$latestLog = Get-ChildItem -Path $logsDir -Filter "mindlab_daily_stack_*.log" `
              | Sort-Object LastWriteTime -Descending `
              | Select-Object -First 1

if (-not $latestLog) {
    Write-Host "[ERROR] No daily stack logs found in: $logsDir"
    Write-Host "        Expected files like mindlab_daily_stack_YYYYMMDD_HHMMSS.log"
    $global:LASTEXITCODE = 1
    exit $global:LASTEXITCODE
}

$logPath = $latestLog.FullName
Write-Host "[INFO] Using latest log file:"
Write-Host "       $logPath"
Write-Host ""

# 3. Extract simple status info from the log
$logText = Get-Content -Path $logPath -Raw

function Find-LineValue {
    param(
        [string]$Text,
        [string]$Prefix
    )
    $line = $Text -split "`r?`n" | Where-Object { $_ -like "$Prefix*" } | Select-Object -First 1
    if (-not $line) { return $null }
    return $line.Substring($Prefix.Length).Trim()
}

# These patterns correspond to the lines written by run_daily_with_error_log.ps1
$dailyExitStr = Find-LineValue -Text $logText -Prefix "Daily routine exit code :"
$uiExitStr    = Find-LineValue -Text $logText -Prefix "UI suite exit code      :"

if (-not $dailyExitStr) { $dailyExitStr = "unknown" }
if (-not $uiExitStr)    { $uiExitStr    = "unknown" }

[int]$dailyExit = 0
[int]$uiExit    = 0
[void][int]::TryParse($dailyExitStr, [ref]$dailyExit)
[void][int]::TryParse($uiExitStr,    [ref]$uiExit)

$overallStatus = if ($dailyExit -eq 0 -and $uiExit -eq 0) { "HEALTHY" } else { "ISSUES" }

Write-Host "[INFO] Daily routine exit code : $dailyExitStr"
Write-Host "[INFO] UI suite exit code      : $uiExitStr"
Write-Host "[INFO] Overall status          : $overallStatus"
Write-Host ""

# 4. Build RTF content
$now       = Get-Date
$timestamp = $now.ToString("yyyyMMdd_HHmmss")
$rtfName   = "mindlab_daily_status_$timestamp.rtf"
$rtfPath   = Join-Path $reportsDir $rtfName

if (-not (Test-Path $reportsDir)) {
    New-Item -ItemType Directory -Path $reportsDir | Out-Null
}

# Basic RTF (escaped backslashes and braces)
# We keep it very simple so Word/WordPad can open it easily
$rtf = @"
{\rtf1\ansi
{\b MindLab Daily Status Report} \line
Generated: $($now.ToString("yyyy-MM-dd HH:mm:ss")) \line
\line
{\b Overall status:} $overallStatus \line
\line
{\b Components:} \line
  - Daily routine exit code: $dailyExitStr \line
  - UI suite exit code: $uiExitStr \line
\line
{\b Log file:} $logPath \line
}
"@

$rtf | Set-Content -Path $rtfPath -Encoding ASCII

Write-Host "[RESULT] Daily RTF summary written to:"
Write-Host "        $rtfPath"

$global:LASTEXITCODE = 0
exit 0
