Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO  = "C:\Projects\MindLab_Starter_Project"
    $BKDIR = "C:\MindLab_Backups"

    Set-Location "C:\"

    $latest = Get-ChildItem -Path $BKDIR -Filter "MindLab_Backup_*.zip" -ErrorAction Stop |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        throw "STOP: no backup zip available"
    }

    $brokenName = "MindLab_Starter_Project_BROKEN_" + (Get-Date -Format "yyyyMMdd_HHmmss")
    $brokenPath = Join-Path "C:\Projects" $brokenName

    if (Test-Path $REPO) {
        Rename-Item -Path $REPO -NewName $brokenName -ErrorAction Stop
    }

    New-Item -ItemType Directory -Force -Path $REPO | Out-Null
    Expand-Archive -Path $latest.FullName -DestinationPath $REPO -Force

    $verifyPaths = @(
        "C:\Projects\MindLab_Starter_Project\tools",
        "C:\Projects\MindLab_Starter_Project\backend"
    )

    $verifyHit = $false
    foreach ($p in $verifyPaths) {
        if (Test-Path $p) {
            $verifyHit = $true
        }
    }

    if (-not $verifyHit) {
        throw "STOP: restore verification failed"
    }

    Write-Host "OK: latest backup restored" -ForegroundColor Green
    Write-Host ("RESTORED_FROM=" + $latest.FullName) -ForegroundColor Green
    if (Test-Path $brokenPath) {
        Write-Host ("BROKEN_REPO_ARCHIVED_AT=" + $brokenPath) -ForegroundColor Yellow
    }

    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
