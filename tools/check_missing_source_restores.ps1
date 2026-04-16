Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$RepoRoot = "C:\Projects\MindLab_Starter_Project"
$ManifestPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\restore_manifest_2026-04-15\kids_missing_source_restore_manifest.csv"
$ReportPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\restore_manifest_2026-04-15\kids_missing_source_restore_check.csv"
function Pause-Safe {
    Set-Location $RepoRoot
    Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
    Set-Location $RepoRoot
}
function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows,[string[]]$HeaderColumns=@())
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    if ($null -eq $Rows -or @($Rows).Count -eq 0) {
        if ($HeaderColumns.Count -gt 0) { [System.IO.File]::WriteAllLines($Path, @($HeaderColumns -join ','), $utf8NoBom) }
        else { [System.IO.File]::WriteAllText($Path, "", $utf8NoBom) }
        return
    }
    $csv = @($Rows | ConvertTo-Csv -NoTypeInformation)
    if ($csv.Count -eq 0) {
        if ($HeaderColumns.Count -gt 0) { [System.IO.File]::WriteAllLines($Path, @($HeaderColumns -join ','), $utf8NoBom) }
        else { [System.IO.File]::WriteAllText($Path, "", $utf8NoBom) }
        return
    }
    [System.IO.File]::WriteAllLines($Path, $csv, $utf8NoBom)
}
if (!(Test-Path $ManifestPath)) { throw "Missing path: $ManifestPath" }
$rows = foreach ($row in Import-Csv $ManifestPath) {
    $pathToCheck = $row.RestoredPath
    if ([string]::IsNullOrWhiteSpace($pathToCheck)) { $pathToCheck = $row.ExactPath }
    [pscustomobject]@{
        Area          = $row.Area
        Item          = $row.Item
        PathChecked   = $pathToCheck
        ExistsNow     = $(if (-not [string]::IsNullOrWhiteSpace($pathToCheck) -and (Test-Path $pathToCheck)) { "YES" } else { "NO" })
        RestoreStatus = $row.RestoreStatus
        RestoreNotes  = $row.RestoreNotes
    }
}
$rows = @($rows)
Write-CsvUtf8NoBom -Path $ReportPath -Rows $rows -HeaderColumns @("Area","Item","PathChecked","ExistsNow","RestoreStatus","RestoreNotes")
$missing = @($rows | Where-Object { $_.ExistsNow -eq "NO" }).Count
if ($missing -eq 0) { Write-Host "OUTCOME:RESTORED_SOURCE_FILES_PRESENT" -ForegroundColor Green }
else { Write-Host "OUTCOME:WAITING_FOR_AUTHORITATIVE_SOURCE_RESTORE_STOP" -ForegroundColor Yellow }
Pause-Safe
