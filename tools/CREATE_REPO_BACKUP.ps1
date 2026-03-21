param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    $BackupRoot = "C:\MindLab_Backups"

    New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $zipPath = Join-Path $BackupRoot ("MindLab_Backup_" + $stamp + ".zip")
    $tempCopy = Join-Path $env:TEMP ("MindLab_Backup_Work_" + $stamp)

    if (Test-Path $tempCopy) {
        Remove-Item $tempCopy -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Force -Path $tempCopy | Out-Null

    robocopy $Repo $tempCopy /MIR /XD ".git" "node_modules" > $null
    $robocopyCode = $LASTEXITCODE
    if ($robocopyCode -ge 8) { throw "STOP: robocopy backup prep failed" }

    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    }

    Compress-Archive -Path (Join-Path $tempCopy "*") -DestinationPath $zipPath -Force

    if (!(Test-Path $zipPath)) { throw "STOP: backup zip missing" }

    Get-Item $zipPath | Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize | Out-Host

    Remove-Item $tempCopy -Recurse -Force -ErrorAction SilentlyContinue

    Complete-Step -Code 0 -Message "OK: backup created"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (Test-Path $tempCopy) {
        Remove-Item $tempCopy -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not $NoPause) { Wait-ForUser }
}
