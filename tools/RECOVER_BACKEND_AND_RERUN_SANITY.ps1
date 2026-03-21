param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    & "C:\Projects\MindLab_Starter_Project\tools\STOP_BACKEND_SAFE.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend stop routine failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\START_BACKEND_SAFE.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend start routine failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\WAIT_FOR_BACKEND_HEALTH.ps1" -NoPause
    if ($LASTEXITCODE -ne 0) { throw "STOP: backend health wait failed" }

    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\MindLab_Starter_Project\tools\SANITY_CHECK_REPO.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: sanity check failed after backend recovery" }

    Complete-Step -Code 0 -Message "OK: backend recovered and sanity passed"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
