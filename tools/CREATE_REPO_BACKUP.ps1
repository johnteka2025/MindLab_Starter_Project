Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO  = "C:\Projects\MindLab_Starter_Project"
    $BKDIR = "C:\MindLab_Backups"

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    New-Item -ItemType Directory -Force -Path $BKDIR | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $zip   = Join-Path $BKDIR ("MindLab_Backup_" + $stamp + ".zip")

    Compress-Archive -Path (Join-Path $REPO "*") -DestinationPath $zip -Force

    if (!(Test-Path $zip)) {
        throw "STOP: backup zip not created"
    }

    Get-Item $zip | Select-Object FullName,Length,LastWriteTime | Out-Host
    Write-Host "OK: backup created" -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
