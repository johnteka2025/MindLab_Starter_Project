Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO  = "C:\Projects\MindLab_Starter_Project"
    $BKDIR = "C:\MindLab_Backups"

    $latest = Get-ChildItem -Path $BKDIR -Filter "MindLab_Backup_*.zip" -ErrorAction Stop |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        throw "STOP: no backup zip available"
    }

    $broken = "C:\Projects\MindLab_Starter_Project_BROKEN_" + (Get-Date -Format "yyyyMMdd_HHmmss")

    if (Test-Path $REPO) {
        Rename-Item -Path $REPO -NewName (Split-Path $broken -Leaf)
    }

    New-Item -ItemType Directory -Force -Path $REPO | Out-Null
    Expand-Archive -Path $latest.FullName -DestinationPath $REPO -Force

    if (!(Test-Path (Join-Path $REPO ".git")) -and !(Test-Path (Join-Path $REPO "package.json"))) {
        throw "STOP: restore verification failed"
    }

    Write-Host "OK: latest backup restored" -ForegroundColor Green
    Write-Host ("RESTORED_FROM=" + $latest.FullName) -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
