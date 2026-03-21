Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    git restore --source=HEAD --staged --worktree .
    if ($LASTEXITCODE -ne 0) { throw "STOP: git restore failed" }

    git clean -fd
    if ($LASTEXITCODE -ne 0) { throw "STOP: git clean failed" }

    git restore --source=HEAD --staged --worktree "tools/backend.pid" 2>$null

    $status = git status --porcelain
    if ($status) {
        Write-Host $status -ForegroundColor Yellow
        throw "STOP: repo still dirty after cleanup"
    }

    Write-Host "OK: repo cleaned to HEAD" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
