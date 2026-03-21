param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    Set-Location $Repo

    $pidFile = "$Repo\tools\backend.pid"
    if (Test-Path $pidFile) { Remove-Item $pidFile -Force -ErrorAction SilentlyContinue }

    $entryCandidates = @(
        "$Repo\backend\server.js",
        "$Repo\backend\app.js",
        "$Repo\backend\index.js",
        "$Repo\server.js"
    )

    $entry = $entryCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $entry) { throw "STOP: backend entry file not found" }

    $logDir = Join-Path $env:TEMP "MindLab_Runtime_Logs"
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null

    $stdout = Join-Path $logDir "backend_stdout.log"
    $stderr = Join-Path $logDir "backend_stderr.log"

    if (Test-Path $stdout) { Remove-Item $stdout -Force -ErrorAction SilentlyContinue }
    if (Test-Path $stderr) { Remove-Item $stderr -Force -ErrorAction SilentlyContinue }

    $proc = Start-Process -FilePath "node" -ArgumentList "`"$entry`"" -WorkingDirectory $Repo -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru
    if (-not $proc) { throw "STOP: backend failed to start" }

    $proc.Id | Set-Content -Path $pidFile -Encoding ASCII

    Start-Sleep -Seconds 8

    if ($proc.HasExited) {
        Write-Host "STOP: backend exited early" -ForegroundColor Yellow
        if (Test-Path $stderr) { Get-Content $stderr -ErrorAction SilentlyContinue | Out-Host }
        Complete-Step -Code 2 -Message "STOP: backend exited early"
        return
    }

    Write-Host ("PID=" + $proc.Id) -ForegroundColor Cyan
    Write-Host ("STDOUT=" + $stdout) -ForegroundColor Cyan
    Write-Host ("STDERR=" + $stderr) -ForegroundColor Cyan

    Complete-Step -Code 0 -Message "OK: backend started"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
