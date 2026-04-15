Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot      = "C:\Projects\MindLab_Starter_Project"
$GovManualPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\01_governance\closure_sync_2026-04-12\governance_manual_exact_path_intake.csv"
$TrkManualPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\tracker_refresh_2026-04-12\tracker_manual_exact_path_intake.csv"

function Pause-Safe {
    Set-Location $RepoRoot
    Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
    Set-Location $RepoRoot
}

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $csv = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path, $csv, (New-Object System.Text.UTF8Encoding($false)))
}

if (!(Test-Path $GovManualPath)) { throw "Missing path: $GovManualPath" }
if (!(Test-Path $TrkManualPath)) { throw "Missing path: $TrkManualPath" }

$govRows = foreach ($row in Import-Csv $GovManualPath) {
    $valid = (-not [string]::IsNullOrWhiteSpace($row.ManualExactPath)) -and ($row.ManualExactPath -ne "TBD") -and (Test-Path $row.ManualExactPath)
    [pscustomobject]@{
        SelectedRole    = $row.SelectedRole
        CandidatePath   = $row.CandidatePath
        ManualExactPath = $row.ManualExactPath
        PathConfirmed   = $(if ($valid) { "YES" } else { "NO" })
        IntakeStatus    = $(if ($valid) { "READY" } else { "PENDING" })
    }
}

$trkRows = foreach ($row in Import-Csv $TrkManualPath) {
    $valid = (-not [string]::IsNullOrWhiteSpace($row.ManualExactPath)) -and ($row.ManualExactPath -ne "TBD") -and (Test-Path $row.ManualExactPath)
    [pscustomobject]@{
        SelectedTarget  = $row.SelectedTarget
        CandidatePath   = $row.CandidatePath
        ManualExactPath = $row.ManualExactPath
        PathConfirmed   = $(if ($valid) { "YES" } else { "NO" })
        IntakeStatus    = $(if ($valid) { "READY" } else { "PENDING" })
    }
}

Write-CsvUtf8NoBom -Path $GovManualPath -Rows $govRows
Write-CsvUtf8NoBom -Path $TrkManualPath -Rows $trkRows

$confirmed = @($govRows | Where-Object { $_.PathConfirmed -eq "YES" }).Count + @($trkRows | Where-Object { $_.PathConfirmed -eq "YES" }).Count
if ($confirmed -gt 0) {
    Write-Host "OUTCOME:MANUAL_INPUT_READY_FOR_REFRESH" -ForegroundColor Green
} else {
    Write-Host "OUTCOME:WAITING_FOR_MANUAL_INPUT_STOP" -ForegroundColor Yellow
}

Pause-Safe