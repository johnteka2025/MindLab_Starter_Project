param(
    [Parameter(Mandatory=$true)]
    [string]$Message,

    [string[]]$Paths
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    Set-Location $REPO

    if ($Paths -and $Paths.Count -gt 0) {
        foreach ($p in $Paths) {
            if (Test-Path $p) {
                git add -- $p
            }
            else {
                throw "STOP: path missing $p"
            }
        }
    }

    $staged = git diff --cached --name-only
    if (-not $staged) {
        Write-Host "STOP: nothing staged" -ForegroundColor Yellow
        Write-Host "FOLLOW-UP: stop commit or rerun with correct paths" -ForegroundColor Yellow
        return
    }

    git commit -m $Message

    if ($LASTEXITCODE -ne 0) {
        git reset
        throw "STOP: commit failed"
    }

    Write-Host "OK: commit completed" -ForegroundColor Green
    git status --porcelain | Out-Host
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
