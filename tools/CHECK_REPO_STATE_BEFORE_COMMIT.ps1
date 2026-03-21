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
    $staged = git diff --cached --name-only

    if (-not $status -and -not $staged) {
        Complete-Step -Code 2 -Message "STOP: nothing to commit; repo already clean"
        return
    }

    Write-Host "STATUS:" -ForegroundColor Cyan
    if ($status) { $status | Out-Host }

    Write-Host "STAGED:" -ForegroundColor Cyan
    if ($staged) { $staged | Out-Host }

    Complete-Step -Code 0 -Message "OK: pending changes detected"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
