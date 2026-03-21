param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git reset
    if ($LASTEXITCODE -ne 0) { throw "STOP: git reset failed" }

    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\MindLab_Starter_Project\tools\RESTORE_LATEST_BACKUP.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: restore latest backup failed" }

    Complete-Step -Code 0 -Message "OK: backup restored after commit failure"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
