param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git restore --source=HEAD --staged --worktree "tools/backend.pid" 2>$null

    $status = git status --porcelain
    $staged = git diff --cached --name-only

    if (-not $status -and -not $staged) {
        Write-Host "STOP: nothing to commit; repo already clean" -ForegroundColor Yellow
        exit 2
    }

    Write-Host "OK: pending changes detected" -ForegroundColor Green
    if ($status) { $status | Out-Host }
    if ($staged) { $staged | Out-Host }
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
