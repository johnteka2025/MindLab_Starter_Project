param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git restore --source=HEAD --staged --worktree .
    if ($LASTEXITCODE -ne 0) { throw "STOP: git restore failed" }

    git clean -fd
    if ($LASTEXITCODE -ne 0) { throw "STOP: git clean failed" }

    git restore --source=HEAD --staged --worktree "tools/backend.pid" 2>$null

    $status = git status --porcelain
    if ($status) {
        $status | Out-Host
        throw "STOP: repo still dirty after cleanup"
    }

    Complete-Step -Code 0 -Message "OK: repo cleaned to HEAD"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
