Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    $staged = git diff --cached --name-only
    if ($staged) {
        Write-Host "OK: staged files exist" -ForegroundColor Green
        $staged | Out-Host
        exit 0
    }

    $status = git status --porcelain
    if (-not $status) {
        Write-Host "STOP: nothing to commit; repo already clean" -ForegroundColor Yellow
        exit 2
    }

    git add -A
    if ($LASTEXITCODE -ne 0) { throw "STOP: git add -A failed" }

    $stagedAfter = git diff --cached --name-only
    if (-not $stagedAfter) {
        throw "STOP: files exist but nothing staged after git add -A"
    }

    Write-Host "OK: staged all pending changes" -ForegroundColor Green
    $stagedAfter | Out-Host
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
