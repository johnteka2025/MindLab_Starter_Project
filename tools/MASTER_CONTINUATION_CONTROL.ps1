Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"
    Set-Location $REPO

    Write-Host "STEP 1: REPO CHECK"
    $status = git status --porcelain
    if ($status) {
        Write-Host "DIRTY_REPO_DETECTED" -ForegroundColor Yellow
        $status | Out-Host
        throw "STOP: repo dirty"
    }

    Write-Host "STEP 2: RUN ALL GATES"
    & "C:\Projects\MindLab_Starter_Project\tools\RUN_ALL_GATES.ps1"

    Write-Host "STEP 3: FINAL STATUS"
    git status --porcelain | Out-Host
    git tag --list | Out-Host

    Write-Host "OK: MASTER CONTINUATION CONTROL PASSED" -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
