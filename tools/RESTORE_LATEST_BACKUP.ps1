param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    $BackupRoot = "C:\MindLab_Backups"

    if (!(Test-Path $BackupRoot)) { throw "STOP: backup root missing" }

    $latest = Get-ChildItem -Path $BackupRoot -Filter "MindLab_Backup_*.zip" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) { throw "STOP: no backup zip found" }

    $extractRoot = Join-Path $env:TEMP ("MindLab_Restore_" + (Get-Date -Format "yyyyMMdd_HHmmss"))

    if (Test-Path $extractRoot) {
        Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null
    Expand-Archive -Path $latest.FullName -DestinationPath $extractRoot -Force

    robocopy $extractRoot $Repo /MIR /XD ".git" > $null
    $robocopyCode = $LASTEXITCODE
    if ($robocopyCode -ge 8) { throw "STOP: restore robocopy failed" }

    Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ("RESTORED_FROM=" + $latest.FullName) -ForegroundColor Cyan
    Complete-Step -Code 0 -Message "OK: latest backup restored"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (Test-Path $extractRoot) {
        Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not $NoPause) { Wait-ForUser }
}
