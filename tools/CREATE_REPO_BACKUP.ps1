Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO  = "C:\Projects\MindLab_Starter_Project"
    $BKDIR = "C:\MindLab_Backups"
    $TEMP  = Join-Path $env:TEMP ("MindLab_Backup_Work_" + (Get-Date -Format "yyyyMMdd_HHmmss"))

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    New-Item -ItemType Directory -Force -Path $BKDIR | Out-Null
    New-Item -ItemType Directory -Force -Path $TEMP  | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $zip   = Join-Path $BKDIR ("MindLab_Backup_" + $stamp + ".zip")

    $allFiles = Get-ChildItem -Path $REPO -Recurse -File -Force -ErrorAction Stop | Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\tools\\logs\\' -and
        $_.Extension -ne ".log"
    }

    if (-not $allFiles) {
        throw "STOP: no files available for backup"
    }

    foreach ($src in $allFiles) {
        $relative = $src.FullName.Substring($REPO.Length).TrimStart('\')
        $dest = Join-Path $TEMP $relative
        $destDir = Split-Path $dest -Parent

        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }

        Copy-Item -LiteralPath $src.FullName -Destination $dest -Force -ErrorAction Stop
    }

    if (!(Test-Path $TEMP)) {
        throw "STOP: backup staging folder missing"
    }

    Compress-Archive -Path (Join-Path $TEMP "*") -DestinationPath $zip -Force

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
    if ($TEMP -and (Test-Path $TEMP)) {
        Remove-Item -LiteralPath $TEMP -Recurse -Force -ErrorAction SilentlyContinue
    }
    Read-Host "Press ENTER (PowerShell stays open)"
}
