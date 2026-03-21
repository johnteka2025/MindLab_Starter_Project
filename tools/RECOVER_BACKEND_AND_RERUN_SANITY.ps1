param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    & "C:\Projects\MindLab_Starter_Project\tools\STOP_BACKEND_SAFE.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend stop routine failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\START_BACKEND_SAFE.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend start routine failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\WAIT_FOR_BACKEND_HEALTH.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend health wait failed" }

    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\MindLab_Starter_Project\tools\SANITY_CHECK_REPO.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: sanity check failed after backend recovery" }

    Write-Host "OK: backend recovered and sanity passed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    if (-not $NoPause) {
        Read-Host "Press ENTER (PowerShell stays open)"
    }
}
