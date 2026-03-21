Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git reset
    if ($LASTEXITCODE -ne 0) { throw "STOP: git reset failed" }

    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\MindLab_Starter_Project\tools\RESTORE_LATEST_BACKUP.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: restore latest backup failed" }

    Write-Host "OK: backup restored after commit failure" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
