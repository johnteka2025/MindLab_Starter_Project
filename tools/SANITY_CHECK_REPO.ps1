Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git restore --source=HEAD --staged --worktree "tools/backend.pid" 2>$null

    $status = git status --porcelain
    if ($status) {
        Write-Host "STOP: repo dirty" -ForegroundColor Yellow
        $status | Out-Host
        exit 2
    }

    & "C:\Projects\MindLab_Starter_Project\tools\CHECK_HEALTH.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: health failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\PRE_FLIGHT_PHASE12.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: pre-flight failed" }

    Write-Host "OK: sanity check passed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
