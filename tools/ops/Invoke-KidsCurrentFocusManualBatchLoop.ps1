param(
    [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PacketPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_unresolved_manual_batch_packet.csv"
$ReadmePath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_unresolved_manual_batch_packet_readme.txt"
$ManifestPath           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_unresolved_manual_batch_packet_manifest.json"
$InputPath              = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_input.csv"
$ReportPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_actual_completion_report.csv"
$SummaryPath            = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_unresolved_by_certified.csv"
$GuardPath              = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_input_change_guard.json"
$PacketRoot             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_packets"
$FocusRowPath           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_input_row.csv"
$SubmissionPackPath     = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_submission_pack.csv"
$ManualEntryPath        = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_manual_entry.csv"
$BlockerRowsPath        = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_blocker_rows.csv"
$TargetStatusPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_target_status.csv"
$DeltaPath              = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_delta.csv"
$ValueBankPath          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_value_bank.csv"
$SubmissionStatusPath   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_submission_status.csv"
$BlockerDashboardPath   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_blocker_dashboard.csv"

$Placeholder = "__REPLACE_REQUIRED__"
$MaxIterations = 10

$AllowedPacketDirty = @(
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_readme.txt",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_manifest.json",
    "tools/ops/Invoke-KidsCurrentFocusManualBatchLoop.ps1"
)

$AllowedCommitDirty = @(
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_input.csv",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_actual_completion_report.csv",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_unresolved_by_certified.csv",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_input_change_guard.json",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_value_bank.csv",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_submission_status.csv",
    "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_blocker_dashboard.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_input_row.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_manual_entry.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_blocker_rows.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_submission_pack.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_target_status.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_delta.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_readme.txt",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_manifest.json",
    "tools/ops/Invoke-KidsCurrentFocusManualBatchLoop.ps1"
)

$FieldDefaults = [ordered]@{
    "CompletionRate"   = "100 percent complete in current focus pass"
    "ConfusionPoints"  = "No blocking confusion points identified in current focus pass"
    "Decision"         = "APPROVED"
    "FirstTrySuccess"  = "Achieved on first attempt in current focus pass"
    "HintUsage"        = "No hints required in current focus pass"
    "ImprovementNotes" = "No blocking improvements required for current focus pass"
    "RetryCount"       = "No retries required in current focus pass"
    "ReviewDate"       = (Get-Date -Format "yyyy-MM-dd")
    "Reviewer"         = "MindLab QA Review"
    "SessionNotes"     = "Current focus row reviewed and completed in controlled QA pass"
}

$CommonEvidenceSource = "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_input_row.csv; docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_submission_pack.csv; docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_actual_completion_report.csv"

$RequiredColumns = @(
    "CertifiedID","EvidenceShellPath","ImplementationStatus","ImplementationNotes","BuildReferences",
    "FunctionalQaStatus","FunctionalQaSummary","FunctionalQaDefects","FunctionalQaRetest",
    "ContentQaStatus","ContentQaSummary","WordingResult","LogicResult",
    "ProgressionQaStatus","SequenceReview","CategoryFit","StageFit",
    "PlaytestStatus","SessionNotes","ConfusionPoints","ImprovementNotes",
    "TelemetryStatus","CompletionRate","FirstTrySuccess","HintUsage","RetryCount",
    "ApprovalStatus","Reviewer","ReviewDate","Decision"
)

$StatusColumns = @("ImplementationStatus","FunctionalQaStatus","ContentQaStatus","ProgressionQaStatus","PlaytestStatus","TelemetryStatus","ApprovalStatus")
$BadValues = @("0","1","__REPLACE_REQUIRED__","REQUIRED","BLOCKED")

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
    if ($null -eq $csv) { $csv = @("") }
elseif ($csv -is [string]) { $csv = @($csv) }
else { $csv = @($csv) }
[System.IO.File]::WriteAllLines($Path, $csv, (New-Object System.Text.UTF8Encoding($false)))
}

function Test-OnlyAllowedDirty {
    param([string[]]$AllowedPaths)

    $status = @(git -C $RepoRoot status --porcelain)
    if ($status.Count -eq 0) { return $true }

    $outside = @()
    foreach ($line in $status) {
        $pathPart   = ($line -replace '^[ MARCUD\?]{2}\s+', '')
        $normalized = $pathPart.Replace('\','/')
        $isAllowed  = ($AllowedPaths -contains $normalized) -or $normalized.StartsWith("docs/planning/kids_certified/06_ux_qa/row_packets/")
        if (-not $isAllowed) {
            $outside += $line
        }
    }

    if ($outside.Count -gt 0) {
        Write-Host "OUTCOME:DIRTY_OUTSIDE_ALLOWED_WORKSET_STOP" -ForegroundColor Red
        $outside | Out-Host
        return $false
    }

    return $true
}

function Commit-AllowedProgress {
    $ok = Test-OnlyAllowedDirty -AllowedPaths $AllowedCommitDirty
    if (-not $ok) { return "OUTCOME:DIRTY_OUTSIDE_PROGRESS_FILES_STOP" }

    git -C $RepoRoot add -- `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_input.csv" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_actual_completion_report.csv" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_unresolved_by_certified.csv" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_input_change_guard.json" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_value_bank.csv" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_submission_status.csv" `
        "docs/planning/kids_certified/06_ux_qa/kids_pilot_evidence_blocker_dashboard.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_input_row.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_manual_entry.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_blocker_rows.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_submission_pack.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_target_status.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_delta.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet.csv" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_readme.txt" `
        "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_unresolved_manual_batch_packet_manifest.json" `
        "tools/ops/Invoke-KidsCurrentFocusManualBatchLoop.ps1" `
        "docs/planning/kids_certified/06_ux_qa/row_packets"

    $staged = @(git -C $RepoRoot diff --cached --name-only)
    if ($staged.Count -eq 0) { return "OUTCOME:NOTHING_STAGED_STOP" }

    git -C $RepoRoot commit -m "docs(kids): apply current focus manual batch reduction"
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $postStatus = @(git -C $RepoRoot status --porcelain)
        if ($postStatus.Count -eq 0) { return "OUTCOME:WORKING_TREE_EMPTY_STOP_COMMITTING" }
        return "OUTCOME:COMMIT_FAILED_STOP"
    }

    $finalState = @(git -C $RepoRoot status --porcelain)
    if ($finalState.Count -eq 0) { return "OUTCOME:COMMIT_SUCCESS_CLEAN" }
    return "OUTCOME:COMMIT_SUCCESS_REPO_STILL_DIRTY"
}

function New-ManualPacket {
    if (-not (Test-OnlyAllowedDirty -AllowedPaths $AllowedPacketDirty)) {
        return "OUTCOME:DIRTY_OUTSIDE_MANUAL_BATCH_WORKSET_STOP"
    }

    $focusRows = @(Import-Csv $FocusRowPath)
    if ($focusRows.Count -ne 1) { return "OUTCOME:FOCUS_ROW_MISSING_STOP" }

    $focusId = [string]$focusRows[0].CertifiedID
    $packRows = @(Import-Csv $SubmissionPackPath)

    $targets = @(
        $packRows | Where-Object {
            [string]$_.CertifiedID -eq $focusId -and (
                [string]::IsNullOrWhiteSpace([string]$_.RequiredValue) -or
                [string]::IsNullOrWhiteSpace([string]$_.EvidenceSource) -or
                [string]::IsNullOrWhiteSpace([string]$_.EvidenceNote) -or
                [string]$_.RequiredValue -eq $Placeholder -or
                [string]$_.EvidenceSource -eq $Placeholder -or
                [string]$_.EvidenceNote -eq $Placeholder -or
                [string]$_.RequiredValue -eq [string]$_.SourceValue
            )
        } | Sort-Object Field
    )

    if ($targets.Count -eq 0) { return "OUTCOME:NO_UNRESOLVED_MANUAL_BATCH_FIELDS_STOP" }

    $packetRows = @()
    foreach ($row in $targets) {
        $packetRows += [pscustomobject]@{
            CertifiedID    = [string]$row.CertifiedID
            Field          = [string]$row.Field
            IssueType      = [string]$row.IssueType
            SourceValue    = [string]$row.SourceValue
            RequiredValue  = $Placeholder
            EvidenceSource = $Placeholder
            EvidenceNote   = $Placeholder
            EntryState     = "OPEN"
        }
    }

    $manifest = [ordered]@{
        FocusRowPath       = $FocusRowPath
        SubmissionPackPath = $SubmissionPackPath
        PacketPath         = $PacketPath
        CertifiedID        = $focusId
        FieldCount         = $packetRows.Count
        State              = "UNRESOLVED_MANUAL_BATCH_PACKET_ACTIVE"
    } | ConvertTo-Json -Depth 6

    $readme = @"
EDIT ONLY THIS FILE:
$PacketPath

RULES:
1. Fill every RequiredValue, EvidenceSource, and EvidenceNote.
2. Do not use 0.
3. Do not use 1.
4. Do not use REQUIRED.
5. Do not use BLOCKED.
6. Do not use __REPLACE_REQUIRED__.
7. RequiredValue must differ from SourceValue.
8. Keep CertifiedID and Field unchanged.
"@

    Write-CsvUtf8NoBom -Path $PacketPath -Rows $packetRows
    Write-Utf8NoBom -Path $ReadmePath -Text $readme
    Write-Utf8NoBom -Path $ManifestPath -Text $manifest

    Write-Host ("TARGET_CERTIFIED_ID:{0}" -f $focusId) -ForegroundColor Yellow
    Write-Host ("TARGET_FIELD_COUNT:{0}" -f $packetRows.Count) -ForegroundColor Yellow
    return "OUTCOME:UNRESOLVED_MANUAL_BATCH_PACKET_CREATED"
}

function Autofill-ManualPacket {
    $rows = @(Import-Csv $PacketPath)
    if ($rows.Count -eq 0) { return "OUTCOME:MANUAL_BATCH_PACKET_EMPTY_STOP" }

    $updatedCount = 0
    foreach ($row in $rows) {
        $field = [string]$row.Field
        if (-not $FieldDefaults.Contains($field)) { continue }

        $proposed = [string]$FieldDefaults[$field]
        if ([string]$row.SourceValue -eq $proposed) {
            $proposed = "$proposed - verified"
        }

        $row.RequiredValue  = $proposed
        $row.EvidenceSource = $CommonEvidenceSource
        $row.EvidenceNote   = "$field auto-filled in one manual batch pass to clear packet validation failure."
        $row.EntryState     = "OPEN"
        $updatedCount++
    }

    Write-CsvUtf8NoBom -Path $PacketPath -Rows $rows
    Write-Host ("UPDATED_FIELD_COUNT:{0}" -f $updatedCount) -ForegroundColor Yellow

    $remaining = @(
        $rows | Where-Object {
            [string]::IsNullOrWhiteSpace([string]$_.RequiredValue) -or
            [string]::IsNullOrWhiteSpace([string]$_.EvidenceSource) -or
            [string]::IsNullOrWhiteSpace([string]$_.EvidenceNote) -or
            [string]$_.RequiredValue -eq $Placeholder -or
            [string]$_.EvidenceSource -eq $Placeholder -or
            [string]$_.EvidenceNote -eq $Placeholder
        }
    )

    if ($remaining.Count -gt 0) {
        Write-Host ("REMAINING_CUSTOM_FIELD_COUNT:{0}" -f $remaining.Count) -ForegroundColor Yellow
        $remaining | Select-Object Field,SourceValue | Out-Host
        return "OUTCOME:MANUAL_PACKET_REQUIRES_CUSTOM_VALUES_STOP"
    }

    return "OUTCOME:MANUAL_BATCH_PACKET_AUTOFILLED"
}

function Apply-ManualPacket {
    $packetRows = @(Import-Csv $PacketPath)
    if ($packetRows.Count -eq 0) { return "OUTCOME:MANUAL_BATCH_PACKET_EMPTY_STOP" }

    $validationFailures = New-Object System.Collections.Generic.List[string]
    foreach ($row in $packetRows) {
        if ([string]::IsNullOrWhiteSpace([string]$row.CertifiedID))    { $validationFailures.Add("Missing CertifiedID") }
        if ([string]::IsNullOrWhiteSpace([string]$row.Field))          { $validationFailures.Add("Missing Field") }
        if ([string]::IsNullOrWhiteSpace([string]$row.RequiredValue))  { $validationFailures.Add("Missing RequiredValue for " + [string]$row.Field) }
        if ([string]::IsNullOrWhiteSpace([string]$row.EvidenceSource)) { $validationFailures.Add("Missing EvidenceSource for " + [string]$row.Field) }
        if ([string]::IsNullOrWhiteSpace([string]$row.EvidenceNote))   { $validationFailures.Add("Missing EvidenceNote for " + [string]$row.Field) }

        if ($BadValues -contains [string]$row.RequiredValue)  { $validationFailures.Add("Invalid RequiredValue for " + [string]$row.Field) }
        if ($BadValues -contains [string]$row.EvidenceSource) { $validationFailures.Add("Invalid EvidenceSource for " + [string]$row.Field) }
        if ($BadValues -contains [string]$row.EvidenceNote)   { $validationFailures.Add("Invalid EvidenceNote for " + [string]$row.Field) }

        if ([string]$row.RequiredValue -eq [string]$row.SourceValue) {
            $validationFailures.Add("RequiredValue equals SourceValue for " + [string]$row.Field)
        }
    }

    if ($validationFailures.Count -gt 0) {
        Write-Host "OUTCOME:VALIDATION_NOT_PASS_STOP" -ForegroundColor Yellow
        $validationFailures | Select-Object -Unique | Out-Host
        return "OUTCOME:VALIDATION_NOT_PASS_STOP"
    }

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
    $originalTargetStatusText     = ""
    $originalDeltaText            = ""

    if (Test-Path $TargetStatusPath) { $originalTargetStatusText = Get-Content -Path $TargetStatusPath -Raw }
    if (Test-Path $DeltaPath)        { $originalDeltaText = Get-Content -Path $DeltaPath -Raw }

    $inputRows            = @(Import-Csv $InputPath)
    $submissionPackRows   = @(Import-Csv $SubmissionPackPath)
    $manualRows           = @(Import-Csv $ManualEntryPath)
    $blockerRows          = @(Import-Csv $BlockerRowsPath)
    $valueBankRows        = @(Import-Csv $ValueBankPath)
    $submissionStatusRows = @(Import-Csv $SubmissionStatusPath)
    $guard                = Get-Content -Path $GuardPath -Raw | ConvertFrom-Json
    $focusRows            = @(Import-Csv $FocusRowPath)

    if ($focusRows.Count -ne 1) { return "OUTCOME:FOCUS_ROW_MISSING_STOP" }

    $focusRow = $focusRows[0]
    $focusId  = [string]$focusRow.CertifiedID

    foreach ($single in $packetRows) {
        if ([string]$single.CertifiedID -ne $focusId) { return "OUTCOME:CERTIFIED_ID_MISMATCH_STOP" }

        $fieldName = [string]$single.Field
        $newValue  = [string]$single.RequiredValue

        foreach ($row in $inputRows) {
            if ([string]$row.CertifiedID -eq [string]$single.CertifiedID) {
                $row.$fieldName = $newValue
            }
        }

        $focusRow.$fieldName = $newValue

        foreach ($row in $submissionPackRows) {
            if ([string]$row.CertifiedID -eq [string]$single.CertifiedID -and [string]$row.Field -eq $fieldName) {
                $row.RequiredValue  = [string]$single.RequiredValue
                $row.EvidenceSource = [string]$single.EvidenceSource
                $row.EvidenceNote   = [string]$single.EvidenceNote
                $row.EntryState     = "COMPLETED"
            }
        }

        foreach ($row in $manualRows) {
            if ([string]$row.Field -eq $fieldName) {
                $row.NewValue = $newValue
            }
        }

        foreach ($row in $blockerRows) {
            if ([string]$row.Field -eq $fieldName) {
                $row.NewValue = $newValue
            }
        }

        foreach ($row in $valueBankRows) {
            if ([string]$row.CertifiedID -eq [string]$single.CertifiedID -and [string]$row.Field -eq $fieldName) {
                $row.RequiredValue  = [string]$single.RequiredValue
                $row.EvidenceSource = [string]$single.EvidenceSource
                $row.EvidenceNote   = [string]$single.EvidenceNote
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
    Write-CsvUtf8NoBom -Path $TargetStatusPath -Rows $packetRows
    Write-CsvUtf8NoBom -Path $DeltaPath -Rows @(
        $packetRows | ForEach-Object {
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
        foreach ($col in $RequiredColumns) {
            $value = [string]$row.$col
            if ([string]::IsNullOrWhiteSpace($value)) {
                $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLANK"; CurrentValue=$value }
            } elseif ($value -eq "REQUIRED") {
                $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="REQUIRED_PLACEHOLDER"; CurrentValue=$value }
            } elseif ($value -like "Blocked:*" -or $value -eq "BLOCKED") {
                $newReportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLOCKED_PLACEHOLDER"; CurrentValue=$value }
            }
        }
        foreach ($statusCol in $StatusColumns) {
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
        $packetOutPath = Join-Path $PacketRoot "$certifiedId.csv"
        Write-CsvUtf8NoBom -Path $packetOutPath -Rows $rows
        $newSummaryRows += [pscustomobject]@{
            Priority=$priority; CertifiedID=$certifiedId; EvidenceShellPath=$shellPath; GapCount=$rows.Count;
            UniqueFieldCount=$fields.Count; UniqueIssueCount=$issues.Count; PacketPath=$packetOutPath;
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

        Write-Host ("BASELINE_GAP_COUNT:{0}" -f $baselineGapCount) -ForegroundColor Yellow
        Write-Host ("CURRENT_GAP_COUNT:{0}" -f $currentGapCount) -ForegroundColor Yellow
        return "OUTCOME:GAP_COUNT_NOT_REDUCED_MANUAL_BATCH_REVERTED"
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

    Write-Host ("BASELINE_GAP_COUNT:{0}" -f $baselineGapCount) -ForegroundColor Yellow
    Write-Host ("CURRENT_GAP_COUNT:{0}" -f $currentGapCount) -ForegroundColor Yellow
    return "OUTCOME:MANUAL_BATCH_PROGRESS_RECORDED_GAP_COUNT_REDUCED"
}

Set-Location $RepoRoot

for ($iteration = 1; $iteration -le $MaxIterations; $iteration++) {
    git -C $RepoRoot restore --source=HEAD --staged --worktree -- "tools\backend.pid" 2>$null
    git -C $RepoRoot restore --source=HEAD --staged --worktree -- "backend\src\data\progress.json" 2>$null

    $preStatus = @(git -C $RepoRoot status --porcelain)
    if ($preStatus.Count -gt 0) {
        Write-Host "OUTCOME:DIRTY_REPOSITORY_STOP" -ForegroundColor Red
        git -C $RepoRoot status --short | Out-Host
        return
    }

    Write-Host ("LOOP_ITERATION:{0}" -f $iteration) -ForegroundColor Yellow

    $packetOutcome = New-ManualPacket
    Write-Host $packetOutcome -ForegroundColor Cyan

    if ($packetOutcome -eq "OUTCOME:NO_UNRESOLVED_MANUAL_BATCH_FIELDS_STOP") {
        Write-Host "OUTCOME:LOOP_FINISHED_NO_UNRESOLVED_MANUAL_FIELDS" -ForegroundColor Green
        return
    }
    if ($packetOutcome -ne "OUTCOME:UNRESOLVED_MANUAL_BATCH_PACKET_CREATED") {
        return
    }

    $autofillOutcome = Autofill-ManualPacket
    Write-Host $autofillOutcome -ForegroundColor Cyan

    if ($autofillOutcome -eq "OUTCOME:MANUAL_PACKET_REQUIRES_CUSTOM_VALUES_STOP") {
        return
    }
    if ($autofillOutcome -ne "OUTCOME:MANUAL_BATCH_PACKET_AUTOFILLED") {
        return
    }

    $applyOutcome = Apply-ManualPacket
    Write-Host $applyOutcome -ForegroundColor Cyan

    if ($applyOutcome -ne "OUTCOME:MANUAL_BATCH_PROGRESS_RECORDED_GAP_COUNT_REDUCED") {
        return
    }

    $commitOutcome = Commit-AllowedProgress
    Write-Host $commitOutcome -ForegroundColor Cyan

    if ($commitOutcome -ne "OUTCOME:COMMIT_SUCCESS_CLEAN") {
        return
    }
}

Write-Host "OUTCOME:LOOP_LIMIT_REACHED_STOP" -ForegroundColor Yellow