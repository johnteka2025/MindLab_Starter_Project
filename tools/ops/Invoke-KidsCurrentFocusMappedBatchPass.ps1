param(
    [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$InputPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_input.csv"
$ReportPath            = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_actual_completion_report.csv"
$SummaryPath           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_unresolved_by_certified.csv"
$GuardPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_input_change_guard.json"
$PacketRoot            = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_packets"
$FocusRowPath          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_input_row.csv"
$SubmissionPackPath    = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_submission_pack.csv"
$ManualEntryPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_manual_entry.csv"
$BlockerRowsPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_blocker_rows.csv"
$TargetStatusPath      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_target_status.csv"
$DeltaPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_delta.csv"
$MapPath               = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_known_value_map.json"
$ValueBankPath         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_value_bank.csv"
$SubmissionStatusPath  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_submission_status.csv"
$BlockerDashboardPath  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_blocker_dashboard.csv"

function Write-Utf8NoBom {
    param([string]$Path,[string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $csv = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path, $csv, (New-Object System.Text.UTF8Encoding($false)))
}

Set-Location $RepoRoot

$allStatus = @(git -C $RepoRoot status --porcelain)
$allowedDirty = @(
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_known_value_map.json",
    "tools/ops/Invoke-KidsCurrentFocusMappedBatchPass.ps1"
)
$outside = @()
foreach ($line in $allStatus) {
    $pathPart   = ($line -replace '^[ MARCUD\?]{2}\s+', '')
    $normalized = $pathPart.Replace('\','/')
    if ($allowedDirty -notcontains $normalized) {
        $outside += $line
    }
}
if ($outside.Count -gt 0) {
    Write-Host "OUTCOME:DIRTY_OUTSIDE_BATCH_WORKSET_STOP" -ForegroundColor Red
    $outside | Out-Host
    return
}

$requiredColumns = @(
    "CertifiedID","EvidenceShellPath","ImplementationStatus","ImplementationNotes","BuildReferences",
    "FunctionalQaStatus","FunctionalQaSummary","FunctionalQaDefects","FunctionalQaRetest",
    "ContentQaStatus","ContentQaSummary","WordingResult","LogicResult",
    "ProgressionQaStatus","SequenceReview","CategoryFit","StageFit",
    "PlaytestStatus","SessionNotes","ConfusionPoints","ImprovementNotes",
    "TelemetryStatus","CompletionRate","FirstTrySuccess","HintUsage","RetryCount",
    "ApprovalStatus","Reviewer","ReviewDate","Decision"
)
$statusColumns = @("ImplementationStatus","FunctionalQaStatus","ContentQaStatus","ProgressionQaStatus","PlaytestStatus","TelemetryStatus","ApprovalStatus")
$badValues = @("0","1","__REPLACE_REQUIRED__","REQUIRED","BLOCKED")

$focusRows = @(Import-Csv $FocusRowPath)
if ($focusRows.Count -ne 1) {
    Write-Host "OUTCOME:FOCUS_ROW_MISSING_STOP" -ForegroundColor Yellow
    return
}

$focusRow = $focusRows[0]
$focusId  = [string]$focusRow.CertifiedID
$map      = Get-Content -Path $MapPath -Raw | ConvertFrom-Json

$originalInputText            = Get-Content -Path $InputPath -Raw
$originalFocusRowText         = Get-Content -Path $FocusRowPath -Raw
$originalSubmissionPackText   = Get-Content -Path $SubmissionPackPath -Raw
$originalManualEntryText      = Get-Content -Path $ManualEntryPath -Raw
$originalBlockerRowsText      = Get-Content -Path $BlockerRowsPath -Raw
$originalReportText           = Get-Content -Path $ReportPath -Raw
$originalSummaryText          = Get-Content -Path $SummaryPath -Raw
$originalValueBankText        = Get-Content -Path $ValueBankPath -Raw
$originalSubmissionStatusText = Get-Content -Path $SubmissionStatusPath -Raw
$originalDashboardText        = Get-Content -Path $BlockerDashboardPath -Raw
$originalGuardText            = Get-Content -Path $GuardPath -Raw
$originalTargetStatusText = ""
if (Test-Path $TargetStatusPath) {
    $originalTargetStatusText = Get-Content -Path $TargetStatusPath -Raw
}
$originalDeltaText = ""
if (Test-Path $DeltaPath) {
    $originalDeltaText = Get-Content -Path $DeltaPath -Raw
}

$inputRows            = @(Import-Csv $InputPath)
$submissionPackRows   = @(Import-Csv $SubmissionPackPath)
$manualRows           = @(Import-Csv $ManualEntryPath)
$blockerRows          = @(Import-Csv $BlockerRowsPath)
$valueBankRows        = @(Import-Csv $ValueBankPath)
$submissionStatusRows = @(Import-Csv $SubmissionStatusPath)
$reportRows           = @(Import-Csv $ReportPath)
$guard                = Get-Content -Path $GuardPath -Raw | ConvertFrom-Json

$focusInputRows = @($inputRows | Where-Object { [string]$_.CertifiedID -eq $focusId })
if ($focusInputRows.Count -ne 1) {
    Write-Host "OUTCOME:FOCUS_ROW_MISSING_STOP" -ForegroundColor Yellow
    return
}

$focusInput = $focusInputRows[0]

$candidates = @()
foreach ($r in $reportRows) {
    if ([string]$r.CertifiedID -ne $focusId) { continue }
    $field = [string]$r.Field
    $entry = $map.PSObject.Properties[$field]
    if ($null -eq $entry) { continue }

    $newValue = [string]$entry.Value.RequiredValue
    $eSource  = [string]$entry.Value.EvidenceSource
    $eNote    = [string]$entry.Value.EvidenceNote
    if ([string]::IsNullOrWhiteSpace($newValue)) { continue }
    if ($badValues -contains $newValue) { continue }
    if ([string]::IsNullOrWhiteSpace($eSource)) { continue }
    if ([string]::IsNullOrWhiteSpace($eNote)) { continue }
    if ($badValues -contains $eSource) { continue }
    if ($badValues -contains $eNote) { continue }

    $currentValue = [string]$focusInput.$field
    if ($currentValue -eq $newValue) { continue }

    $candidates += [pscustomobject]@{
        CertifiedID    = $focusId
        Field          = $field
        SourceValue    = $currentValue
        RequiredValue  = $newValue
        EvidenceSource = $eSource
        EvidenceNote   = $eNote
    }
}

if ($candidates.Count -eq 0) {
    Write-Host "OUTCOME:NO_MAPPED_BATCH_CHANGES_STOP" -ForegroundColor Yellow
    return
}

foreach ($c in $candidates) {
    $field = [string]$c.Field
    $newValue = [string]$c.RequiredValue

    $focusInput.$field = $newValue
    $focusRow.$field   = $newValue

    foreach ($row in $inputRows) {
        if ([string]$row.CertifiedID -eq $focusId) {
            $row.$field = $newValue
        }
    }
    foreach ($row in $submissionPackRows) {
        if ([string]$row.CertifiedID -eq $focusId -and [string]$row.Field -eq $field) {
            $row.RequiredValue  = [string]$c.RequiredValue
            $row.EvidenceSource = [string]$c.EvidenceSource
            $row.EvidenceNote   = [string]$c.EvidenceNote
            $row.EntryState     = "COMPLETED"
        }
    }
    foreach ($row in $manualRows) {
        if ([string]$row.Field -eq $field) {
            $row.NewValue = $newValue
        }
    }
    foreach ($row in $blockerRows) {
        if ([string]$row.Field -eq $field) {
            $row.NewValue = $newValue
        }
    }
    foreach ($row in $valueBankRows) {
        if ([string]$row.CertifiedID -eq $focusId -and [string]$row.Field -eq $field) {
            $row.RequiredValue  = [string]$c.RequiredValue
            $row.EvidenceSource = [string]$c.EvidenceSource
            $row.EvidenceNote   = [string]$c.EvidenceNote
            $row.EntryState     = "COMPLETED"
        }
    }
}

foreach ($row in $submissionStatusRows) {
    if ([string]$row.CertifiedID -eq $focusId) {
        $row.SubmissionState = "UPDATED"
    }
}

Write-CsvUtf8NoBom -Path $InputPath -Rows $inputRows
Write-CsvUtf8NoBom -Path $FocusRowPath -Rows @($focusRow)
Write-CsvUtf8NoBom -Path $SubmissionPackPath -Rows $submissionPackRows
Write-CsvUtf8NoBom -Path $ManualEntryPath -Rows $manualRows
Write-CsvUtf8NoBom -Path $BlockerRowsPath -Rows $blockerRows
Write-CsvUtf8NoBom -Path $ValueBankPath -Rows $valueBankRows
Write-CsvUtf8NoBom -Path $SubmissionStatusPath -Rows $submissionStatusRows
Write-CsvUtf8NoBom -Path $TargetStatusPath -Rows $candidates
Write-CsvUtf8NoBom -Path $DeltaPath -Rows @(
    $candidates | ForEach-Object {
        [pscustomobject]@{
            CertifiedID  = [string]$_.CertifiedID
            Field        = [string]$_.Field
            SourceValue  = [string]$_.SourceValue
            AppliedValue = [string]$_.RequiredValue
            IsDifferent  = ([string]$_.SourceValue -ne [string]$_.RequiredValue)
        }
    }
)

$newReportRows = @()
foreach ($row in $inputRows) {
    foreach ($col in $requiredColumns) {
        $value = [string]$row.$col
        if ([string]::IsNullOrWhiteSpace($value)) {
            $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLANK"; CurrentValue=$value }
        } elseif ($value -eq "REQUIRED") {
            $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="REQUIRED_PLACEHOLDER"; CurrentValue=$value }
        } elseif ($value -like "Blocked:*" -or $value -eq "BLOCKED") {
            $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLOCKED_PLACEHOLDER"; CurrentValue=$value }
        }
    }
    foreach ($statusCol in $statusColumns) {
        $statusValue = [string]$row.$statusCol
        if ($statusValue -ne "COMPLETE") {
            $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$statusCol; Issue="STATUS_NOT_COMPLETE"; CurrentValue=$statusValue }
        }
    }
}

$newSummaryRows = @()
$priority = 1
foreach ($group in ($newReportRows | Group-Object CertifiedID | Sort-Object Name)) {
    $rows = @($group.Group)
    $certifiedId = $group.Name
    $shellPath = ($rows | Select-Object -First 1).EvidenceShellPath
    $fields = @($rows | Select-Object -ExpandProperty Field -Unique | Sort-Object)
    $issues = @($rows | Select-Object -ExpandProperty Issue -Unique | Sort-Object)
    $packetPath = Join-Path $PacketRoot "$certifiedId.csv"
    Write-CsvUtf8NoBom -Path $packetPath -Rows $rows
    $newSummaryRows += [pscustomobject]@{
        Priority=$priority; CertifiedID=$certifiedId; EvidenceShellPath=$shellPath; GapCount=$rows.Count;
        UniqueFieldCount=$fields.Count; UniqueIssueCount=$issues.Count; PacketPath=$packetPath;
        FieldsToFix=($fields -join "; "); IssueTypes=($issues -join "; "); State="OPEN"
    }
    $priority++
}

$dashboardGroups = $newReportRows | Group-Object CertifiedID
$blockerDashboardRows = @()
foreach ($g in $dashboardGroups) {
    $rows = @($g.Group)
    $blockerDashboardRows += [pscustomobject]@{
        CertifiedID=[string]$g.Name
        TotalGapCount=$rows.Count
        BlankCount=@($rows | Where-Object { [string]$_.Issue -eq "BLANK" }).Count
        RequiredPlaceholderCount=@($rows | Where-Object { [string]$_.Issue -eq "REQUIRED_PLACEHOLDER" }).Count
        BlockedPlaceholderCount=@($rows | Where-Object { [string]$_.Issue -eq "BLOCKED_PLACEHOLDER" }).Count
        StatusNotCompleteCount=@($rows | Where-Object { [string]$_.Issue -eq "STATUS_NOT_COMPLETE" }).Count
        DashboardState="OPEN"
    }
}

Write-CsvUtf8NoBom -Path $ReportPath -Rows $newReportRows
Write-CsvUtf8NoBom -Path $SummaryPath -Rows $newSummaryRows
Write-CsvUtf8NoBom -Path $BlockerDashboardPath -Rows $blockerDashboardRows

$currentGapCount  = $newReportRows.Count
$baselineGapCount = [int]$guard.GapCount

if ($currentGapCount -ge $baselineGapCount) {
    Write-Utf8NoBom -Path $InputPath -Text $originalInputText
    Write-Utf8NoBom -Path $FocusRowPath -Text $originalFocusRowText
    Write-Utf8NoBom -Path $SubmissionPackPath -Text $originalSubmissionPackText
    Write-Utf8NoBom -Path $ManualEntryPath -Text $originalManualEntryText
    Write-Utf8NoBom -Path $BlockerRowsPath -Text $originalBlockerRowsText
    Write-Utf8NoBom -Path $ReportPath -Text $originalReportText
    Write-Utf8NoBom -Path $SummaryPath -Text $originalSummaryText
    Write-Utf8NoBom -Path $ValueBankPath -Text $originalValueBankText
    Write-Utf8NoBom -Path $SubmissionStatusPath -Text $originalSubmissionStatusText
    Write-Utf8NoBom -Path $BlockerDashboardPath -Text $originalDashboardText
    Write-Utf8NoBom -Path $GuardPath -Text $originalGuardText
    if ($originalTargetStatusText.Length -gt 0) { Write-Utf8NoBom -Path $TargetStatusPath -Text $originalTargetStatusText }
    if ($originalDeltaText.Length -gt 0)       { Write-Utf8NoBom -Path $DeltaPath -Text $originalDeltaText }

    Write-Host ("APPLIED_FIELDS:{0}" -f (($candidates | Select-Object -ExpandProperty Field) -join ",")) -ForegroundColor Yellow
    Write-Host ("BASELINE_GAP_COUNT:{0}" -f $baselineGapCount) -ForegroundColor Yellow
    Write-Host ("CURRENT_GAP_COUNT:{0}" -f $currentGapCount) -ForegroundColor Yellow
    Write-Host "OUTCOME:GAP_COUNT_NOT_REDUCED_BATCH_REVERTED" -ForegroundColor Yellow
    return
}

$newGuard = [ordered]@{
    BaselineCreatedUtc = [DateTime]::UtcNow.ToString("o")
    InputPath          = $InputPath
    ReportPath         = $ReportPath
    SummaryPath        = $SummaryPath
    PacketRoot         = $PacketRoot
    InputHashSha256    = (Get-FileHash -Algorithm SHA256 -Path $InputPath).Hash
    ReportHashSha256   = (Get-FileHash -Algorithm SHA256 -Path $ReportPath).Hash
    GapCount           = $currentGapCount
    CertifiedIdCount   = $newSummaryRows.Count
    State              = "PROGRESS_RECORDED"
} | ConvertTo-Json -Depth 6

Write-Utf8NoBom -Path $GuardPath -Text $newGuard

Write-Host ("APPLIED_FIELDS:{0}" -f (($candidates | Select-Object -ExpandProperty Field) -join ",")) -ForegroundColor Green
Write-Host ("BASELINE_GAP_COUNT:{0}" -f $baselineGapCount) -ForegroundColor Yellow
Write-Host ("CURRENT_GAP_COUNT:{0}" -f $currentGapCount) -ForegroundColor Yellow
Write-Host "OUTCOME:BATCH_PROGRESS_RECORDED_GAP_COUNT_REDUCED" -ForegroundColor Green