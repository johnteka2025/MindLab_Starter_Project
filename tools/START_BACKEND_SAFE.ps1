Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

    $logDir = "$Repo\release_archive\2026-03-21"
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $stdout = "$logDir\backend_stdout.log"
    $stderr = "$logDir\backend_stderr.log"

    $proc = Start-Process -FilePath "node" -ArgumentList "`"$entry`"" -WorkingDirectory $Repo -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru
    if (-not $proc) { throw "STOP: backend failed to start" }

    $proc.Id | Set-Content -Path $pidFile -Encoding ASCII

    Start-Sleep -Seconds 8

    if ($proc.HasExited) {
        Write-Host "STOP: backend exited early" -ForegroundColor Yellow
        if (Test-Path $stderr) { Get-Content $stderr -ErrorAction SilentlyContinue | Out-Host }
        exit 2
    }

    Write-Host "OK: backend started" -ForegroundColor Green
    Write-Host "PID=$($proc.Id)" -ForegroundColor Cyan
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
