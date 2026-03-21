param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git restore --source=HEAD --staged --worktree "tools/backend.pid" 2>$null

    $status = git status --porcelain
    if ($status) {
        Write-Host "STOP: repo dirty" -ForegroundColor Yellow
        $status | Out-Host
        Complete-Step -Code 2 -Message "STOP: repo dirty"
        return
    }

    & "C:\Projects\MindLab_Starter_Project\tools\CHECK_HEALTH.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: health failed" }

    & "C:\Projects\MindLab_Starter_Project\tools\PRE_FLIGHT_PHASE12.ps1"
    if ($LASTEXITCODE -ne 0) { throw "STOP: pre-flight failed" }

    Complete-Step -Code 0 -Message "OK: sanity check passed"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
