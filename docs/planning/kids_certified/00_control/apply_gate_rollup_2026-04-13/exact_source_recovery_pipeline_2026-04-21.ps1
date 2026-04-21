Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot         = "C:\Projects\MindLab_Starter_Project"
$ProgressJson     = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$ExternalInboxCsv = "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv"
$TemplateCsv      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv"
$TemplateTxt      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.txt"
$ReadyImportCsv   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv"
$ReadyImportTxt   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.txt"
$TargetIntakeCsv  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv"
$FinalStatusCsv   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv"
$BlockerStatusCsv = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv"
$BackupDir        = "C:\Projects\MindLab_Starter_Project_Backups\2026-04-21"

function Pause-Safe {
    Set-Location "C:\Projects\MindLab_Starter_Project"
    Read-Host "Press ENTER after review" | Out-Null
    Set-Location "C:\Projects\MindLab_Starter_Project"
}

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $csv = @($Rows) | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path,$csv,(New-Object System.Text.UTF8Encoding($false)))
}

function Write-TextUtf8NoBom {
    param([string]$Path,[string[]]$Lines)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllLines($Path,$Lines,(New-Object System.Text.UTF8Encoding($false)))
}

function Get-DirtyEntries {
    param([string]$Root)
    $entries = @()
    foreach ($line in @(git -C $Root status --porcelain)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $entries += [pscustomobject]@{
            Status = $line.Substring(0,2)
            Path   = ($line.Substring(3)).Trim()
        }
    }
    return @($entries)
}

foreach ($path in @(
    "C:\Projects\MindLab_Starter_Project",
    "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json",
    "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv"
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

$dirtyStart = @(Get-DirtyEntries -Root "C:\Projects\MindLab_Starter_Project")
$allowedDirty = @(
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.txt",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.txt",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/final_lane_status_2026-04-21.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/exact_source_blocked_status_2026-04-21.csv"
)
$unexpectedDirty = @($dirtyStart | Where-Object { $_.Path -notin $allowedDirty })
if ($unexpectedDirty.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    $unexpectedDirty | ForEach-Object { Write-Host $_.Path -ForegroundColor Red }
    Pause-Safe
    return
}

$externalRows = @(Import-Csv -Path "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv")
$templateRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv")
$existingReadyRows = if (Test-Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv") { @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv") } else { @() }

$externalApproved = @($externalRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })
$templateApproved = @($templateRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })
$existingReadyApproved = @($existingReadyRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })

$sourceName = ""
$sourceRows  = @()

if ($externalApproved.Count -gt 0) {
    $sourceName = "EXTERNAL_INBOX"
    $sourceRows = $externalApproved
}
elseif ($templateApproved.Count -gt 0) {
    $sourceName = "TEMPLATE"
    $sourceRows = $templateApproved
}
elseif ($existingReadyApproved.Count -gt 0) {
    $sourceName = "READY_IMPORT"
    $sourceRows = $existingReadyApproved
}
else {
    Write-Host "RESULT: WAITING_FOR_EXTERNAL_APPROVED_VALUES_STOP" -ForegroundColor Yellow
    Write-Host "ExternalApprovedRows=0" -ForegroundColor Yellow
    Write-Host "TemplateApprovedRows=0" -ForegroundColor Yellow
    Write-Host "ReadyImportApprovedRows=0" -ForegroundColor Yellow
    Pause-Safe
    return
}

$invalidRows = @($sourceRows | Where-Object {
    [string]::IsNullOrWhiteSpace([string]$_.ItemKey) -or
    [string]::IsNullOrWhiteSpace([string]$_.FieldName) -or
    [string]::IsNullOrWhiteSpace([string]$_.ApprovalSource) -or
    [string]::IsNullOrWhiteSpace([string]$_.ApprovedBy) -or
    [string]::IsNullOrWhiteSpace([string]$_.ApprovedDate)
})
if ($invalidRows.Count -gt 0) {
    Write-Host "RESULT: EXTERNAL_APPROVED_VALUES_INCOMPLETE_STOP" -ForegroundColor Red
    Write-Host "InvalidRows=$($invalidRows.Count)" -ForegroundColor Red
    Pause-Safe
    return
}

$normalizedRows = @($sourceRows | ForEach-Object {
    [pscustomobject]@{
        LaneName          = "Wave2_SignoffCheckpoint_ExactSource"
        ItemKey           = [string]$_.ItemKey
        FieldName         = [string]$_.FieldName
        ApprovedNewValue  = [string]$_.ApprovedNewValue
        ApprovalSource    = [string]$_.ApprovalSource
        ApprovedBy        = [string]$_.ApprovedBy
        ApprovedDate      = [string]$_.ApprovedDate
        EvidenceReference = [string]$_.EvidenceReference
        Notes             = "Recovered through deterministic pipeline"
    }
})

Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv" -Rows $normalizedRows
Write-TextUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.txt" -Lines @(
    "RESULT: EXTERNAL_APPROVED_VALUES_FILE_READY",
    "ApprovedRows=$($normalizedRows.Count)",
    "Source=$sourceName"
)

$readyRows = @($normalizedRows | ForEach-Object {
    [pscustomobject]@{
        LaneName          = [string]$_.LaneName
        ItemKey           = [string]$_.ItemKey
        FieldName         = [string]$_.FieldName
        ApprovedNewValue  = [string]$_.ApprovedNewValue
        ApprovalSource    = [string]$_.ApprovalSource
        ApprovedBy        = [string]$_.ApprovedBy
        ApprovedDate      = [string]$_.ApprovedDate
        EvidenceReference = [string]$_.EvidenceReference
        IntakeMatched     = ""
    }
})
Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv" -Rows $readyRows
Write-TextUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.txt" -Lines @(
    "RESULT: EXACT_SOURCE_READY_IMPORT_CREATED",
    "ApprovedRows=$($readyRows.Count)",
    "Source=$sourceName"
)

$targetRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv")
if ($targetRows.Count -eq 0) {
    Write-Host "RESULT: TARGET_INTAKE_EMPTY_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

$targetHasItemKey   = $targetRows[0].PSObject.Properties.Name -contains "ItemKey"
$targetHasFieldName = $targetRows[0].PSObject.Properties.Name -contains "FieldName"

if (-not $targetHasItemKey -and -not $targetHasFieldName) {
    Write-Host "RESULT: TARGET_MATCH_COLUMNS_MISSING_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

foreach ($row in $targetRows) {
    foreach ($col in @("ApprovedNewValue","ApprovalSource","ApprovedBy","ApprovedDate","EvidenceReference")) {
        if (-not ($row.PSObject.Properties.Name -contains $col)) {
            $row | Add-Member -NotePropertyName $col -NotePropertyValue ""
        }
    }
}

$missingMatches = @()
$changedCount = 0

foreach ($ready in $readyRows) {
    $match = $null
    if ($targetHasItemKey -and $targetHasFieldName) {
        $match = $targetRows | Where-Object {
            [string]$_.ItemKey -eq [string]$ready.ItemKey -and
            [string]$_.FieldName -eq [string]$ready.FieldName
        } | Select-Object -First 1
    }
    elseif ($targetHasItemKey) {
        $match = $targetRows | Where-Object {
            [string]$_.ItemKey -eq [string]$ready.ItemKey
        } | Select-Object -First 1
    }
    elseif ($targetHasFieldName) {
        $match = $targetRows | Where-Object {
            [string]$_.FieldName -eq [string]$ready.FieldName
        } | Select-Object -First 1
    }

    if ($null -eq $match) {
        $missingMatches += "$($ready.ItemKey)|$($ready.FieldName)"
        continue
    }

    $ready.IntakeMatched = "Y"

    foreach ($pair in @(
        @{ Name = "ApprovedNewValue"; Value = [string]$ready.ApprovedNewValue },
        @{ Name = "ApprovalSource";   Value = [string]$ready.ApprovalSource },
        @{ Name = "ApprovedBy";       Value = [string]$ready.ApprovedBy },
        @{ Name = "ApprovedDate";     Value = [string]$ready.ApprovedDate },
        @{ Name = "EvidenceReference";Value = [string]$ready.EvidenceReference }
    )) {
        if ([string]$match.$($pair.Name) -ne [string]$pair.Value) {
            $match.$($pair.Name) = [string]$pair.Value
            $changedCount++
        }
    }
}

if ($missingMatches.Count -gt 0) {
    Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv" -Rows $readyRows
    Write-Host "RESULT: READY_IMPORT_MATCH_MISSING_STOP" -ForegroundColor Red
    $missingMatches | Select-Object -Unique | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Pause-Safe
    return
}

if ($changedCount -eq 0) {
    Write-Host "RESULT: NOTHING_TO_COMMIT_STOP" -ForegroundColor Yellow
    Pause-Safe
    return
}

if (!(Test-Path "C:\Projects\MindLab_Starter_Project_Backups\2026-04-21")) {
    New-Item -ItemType Directory -Force -Path "C:\Projects\MindLab_Starter_Project_Backups\2026-04-21" | Out-Null
}
$backupPath = Join-Path "C:\Projects\MindLab_Starter_Project_Backups\2026-04-21" ((Get-Date -Format "yyyyMMdd_HHmmss") + "_wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv")
Copy-Item -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv" -Destination $backupPath -Force

Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv" -Rows $targetRows
Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv" -Rows $readyRows

$statusRows  = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv")
$blockerRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv")

if ($statusRows.Count -gt 0) {
    $statusRows[0].ExactSourceLaneStatus = "READY_FOR_DOWNSTREAM_PROPAGATION"
    $statusRows[0].NextValidAction       = "REFRESH_DOWNSTREAM_WAVE2_PATCH_TEMPLATES"
    $statusRows[0].StatusDate            = "2026-04-21"
    Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv" -Rows $statusRows
}
if ($blockerRows.Count -gt 0) {
    $blockerRows[0].BlockStatus     = "CLEARED"
    $blockerRows[0].BlockReason     = "APPROVED_VALUES_RECEIVED_AND_APPLIED"
    $blockerRows[0].ResumeCondition = "READY_IMPORT_APPLIED"
    $blockerRows[0].CheckedOn       = "2026-04-21"
    Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv" -Rows $blockerRows
}

git -C "C:\Projects\MindLab_Starter_Project" add -- `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.txt" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.txt" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/final_lane_status_2026-04-21.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/exact_source_blocked_status_2026-04-21.csv"

$staged = @(git -C "C:\Projects\MindLab_Starter_Project" diff --cached --name-only)
if ($staged.Count -eq 0) {
    Write-Host "RESULT: NOTHING_TO_COMMIT_STOP" -ForegroundColor Yellow
    Pause-Safe
    return
}

git -C "C:\Projects\MindLab_Starter_Project" commit -m "Recover exact-source lane with deterministic approval pipeline"
if ($LASTEXITCODE -ne 0) {
    Write-Host "RESULT: COMMIT_FAILURE_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

Write-Host "RESULT: COMMIT_SUCCESS" -ForegroundColor Green
Write-Host "BackupFile=$backupPath" -ForegroundColor Green
Write-Host "RESULT: EXACT_SOURCE_LANE_RECOVERED" -ForegroundColor Green
git -C "C:\Projects\MindLab_Starter_Project" show --stat --oneline -1

Pause-Safe