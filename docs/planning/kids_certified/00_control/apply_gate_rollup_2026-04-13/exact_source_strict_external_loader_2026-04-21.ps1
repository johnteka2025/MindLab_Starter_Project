Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot         = "C:\Projects\MindLab_Starter_Project"
$ProgressJson     = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$ExternalInboxCsv = "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv"
$RequestPackCsv   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_missing_external_values_request_2026-04-21.csv"
$RecoveryPs1      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_recovery_pipeline_2026-04-21.ps1"

function Pause-Safe {
    Set-Location "C:\Projects\MindLab_Starter_Project"
    Read-Host "Press ENTER after review" | Out-Null
    Set-Location "C:\Projects\MindLab_Starter_Project"
}

function Get-FirstColumnName {
    param([object[]]$Rows,[string[]]$Candidates)
    if ($Rows.Count -eq 0) { return $null }
    foreach ($name in $Candidates) {
        if ($Rows[0].PSObject.Properties.Name -contains $name) { return $name }
    }
    return $null
}

foreach ($path in @(
    "C:\Projects\MindLab_Starter_Project",
    "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json",
    "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_missing_external_values_request_2026-04-21.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_recovery_pipeline_2026-04-21.ps1"
)) {
    if (!(Test-Path $path)) {
        Write-Host "RESULT: REQUIRED_PATH_MISSING_STOP" -ForegroundColor Red
        Write-Host $path -ForegroundColor Red
        Pause-Safe
        return
    }
}

git -C "C:\Projects\MindLab_Starter_Project" restore --source=HEAD --staged --worktree -- "tools\backend.pid" 2>$null
git -C "C:\Projects\MindLab_Starter_Project" restore --source=HEAD --staged --worktree -- "backend\src\data\progress.json" 2>$null

$externalRows = @(Import-Csv -Path "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv")
$requestRows  = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_missing_external_values_request_2026-04-21.csv")

$extItemCol      = Get-FirstColumnName -Rows $externalRows -Candidates @("ItemKey","Key","RequestItemKey","EvidenceItem")
$extFieldCol     = Get-FirstColumnName -Rows $externalRows -Candidates @("FieldName","Field","RequestedField")
$extApprovedCol  = Get-FirstColumnName -Rows $externalRows -Candidates @("ApprovedNewValue","NewValue","Value","ApprovedValue")
$extSourceCol    = Get-FirstColumnName -Rows $externalRows -Candidates @("ApprovalSource","Source")
$extApprovedByCol= Get-FirstColumnName -Rows $externalRows -Candidates @("ApprovedBy","Approver")
$extApprovedDtCol= Get-FirstColumnName -Rows $externalRows -Candidates @("ApprovedDate","ApprovalDate","Date")

$missingColumns = @()
foreach ($pair in @(
    @{ Name="ItemKey"; Value=$extItemCol },
    @{ Name="FieldName"; Value=$extFieldCol },
    @{ Name="ApprovedNewValue"; Value=$extApprovedCol },
    @{ Name="ApprovalSource"; Value=$extSourceCol },
    @{ Name="ApprovedBy"; Value=$extApprovedByCol },
    @{ Name="ApprovedDate"; Value=$extApprovedDtCol }
)) {
    if ([string]::IsNullOrWhiteSpace([string]$pair.Value)) { $missingColumns += $pair.Name }
}

if ($missingColumns.Count -gt 0) {
    Write-Host "RESULT: EXTERNAL_INBOX_SCHEMA_INVALID_STOP" -ForegroundColor Red
    Write-Host "MissingColumns=$([string]::Join('|',$missingColumns))" -ForegroundColor Red
    Pause-Safe
    return
}

$approvedRows = @($externalRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.$extApprovedCol) })
if ($approvedRows.Count -eq 0) {
    Write-Host "RESULT: WAITING_FOR_EXTERNAL_APPROVED_VALUES_STOP" -ForegroundColor Yellow
    Write-Host "ExternalApprovedRows=0" -ForegroundColor Yellow
    Pause-Safe
    return
}

$approvedPairs = @($approvedRows | ForEach-Object { "{0}|{1}" -f [string]$_.$extItemCol,[string]$_.$extFieldCol } | Sort-Object -Unique)
$requiredPairs = @($requestRows | Where-Object {
    ($_.PSObject.Properties.Name -contains "ItemKey") -and
    ($_.PSObject.Properties.Name -contains "FieldName") -and
    -not [string]::IsNullOrWhiteSpace([string]$_.ItemKey) -and
    -not [string]::IsNullOrWhiteSpace([string]$_.FieldName)
} | ForEach-Object { "{0}|{1}" -f [string]$_.ItemKey,[string]$_.FieldName } | Sort-Object -Unique)

$missingCoverage = @($requiredPairs | Where-Object { $_ -notin $approvedPairs })
if ($missingCoverage.Count -gt 0) {
    Write-Host "RESULT: EXTERNAL_VALUE_COVERAGE_INCOMPLETE_STOP" -ForegroundColor Red
    Write-Host "MissingCoverageRows=$($missingCoverage.Count)" -ForegroundColor Red
    Pause-Safe
    return
}

& "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_recovery_pipeline_2026-04-21.ps1"

Pause-Safe