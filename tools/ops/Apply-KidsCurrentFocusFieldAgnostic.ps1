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
$FocusJsonPath         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus.json"
$FocusRowPath          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_input_row.csv"
$ManualEntryPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_manual_entry.csv"
$BlockerRowsPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_blocker_rows.csv"
$SubmissionPackPath    = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_submission_pack.csv"
$SingleRowPath         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_single_submission_row.csv"
$ValueBankPath         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_value_bank.csv"
$SubmissionStatusPath  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_submission_status.csv"
$BlockerDashboardPath  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_blocker_dashboard.csv"
$TargetStatusPath      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_target_status.csv"
$DeltaPath             = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_delta.csv"
$ValidationReport      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_single_submission_row_validation_report.csv"

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
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_single_submission_row.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_single_submission_row_validation_report.csv",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_single_submission_row_readme.txt",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_single_submission_row_manifest.json",
    "docs/planning/kids_certified/06_ux_qa/row_lock/current_focus_known_value_map.json",
    "tools/ops/Apply-KidsCurrentFocusFieldAgnostic.ps1"
)
$outside = @()
foreach ($line in $allStatus) {
    $pathPart = ($line -replace '^[ MARCUD\?]{2}\s+', '')
    $normalized = ($pathPart -replace '\\','/')
    if ($allowedDirty -notcontains $normalized) { $outside += $line }
}
if ($outside.Count -gt 0) {
    Write-Host "OUTCOME:DIRTY_OUTSIDE_SINGLE_ROW_APPLY_STOP" -ForegroundColor Red
    $outside | Out-Host
    return
}

$validationRows = @(Import-Csv $ValidationReport)
if ($validationRows.Count -ne 1 -or [string]$validationRows[0].ValidationState -ne "PASS") {
    Write-Host "OUTCOME:VALIDATION_NOT_PASS_STOP" -ForegroundColor Yellow
    return
}

$focus                = Get-Content -Path $FocusJsonPath -Raw | ConvertFrom-Json
$guard                = Get-Content -Path $GuardPath -Raw | ConvertFrom-Json
$singleRows           = @(Import-Csv $SingleRowPath)
$submissionRows       = @(Import-Csv $SubmissionPackPath)
$manualRows           = @(Import-Csv $ManualEntryPath)
$blockerRows          = @(Import-Csv $BlockerRowsPath)
$inputRows            = @(Import-Csv $InputPath)
$focusRow             = @($inputRows | Where-Object { [string]$_.CertifiedID -eq [string]$focus.CertifiedID })
$valueBankRows        = @(Import-Csv $ValueBankPath)
$submissionStatusRows = @(Import-Csv $SubmissionStatusPath)

if ($focusRow.Count -ne 1)   { throw "Expected exactly one row for $($focus.CertifiedID)" }
if ($singleRows.Count -ne 1) { throw "Expected exactly one single submission row" }

$single    = $singleRows[0]
$fieldName = [string]$single.Field
$newValue  = [string]$single.RequiredValue

foreach ($row in $submissionRows) {
    if ([string]$row.CertifiedID -eq [string]$single.CertifiedID -and [string]$row.Field -eq $fieldName) {
        $row.RequiredValue  = [string]$single.RequiredValue
        $row.EvidenceSource = [string]$single.EvidenceSource
        $row.EvidenceNote   = [string]$single.EvidenceNote
        $row.EntryState     = "COMPLETED"
    }
}
foreach ($row in $manualRows)  { if ([string]$row.Field -eq $fieldName) { $row.NewValue = $newValue } }
foreach ($row in $blockerRows) { if ([string]$row.Field -eq $fieldName) { $row.NewValue = $newValue } }

$focusRow[0].$fieldName = $newValue
foreach ($row in $inputRows) {
    if ([string]$row.CertifiedID -eq [string]$focus.CertifiedID) { $row.$fieldName = $newValue }
}

Write-CsvUtf8NoBom -Path $SubmissionPackPath -Rows $submissionRows
Write-CsvUtf8NoBom -Path $ManualEntryPath -Rows $manualRows
Write-CsvUtf8NoBom -Path $BlockerRowsPath -Rows $blockerRows
Write-CsvUtf8NoBom -Path $FocusRowPath -Rows $focusRow
Write-CsvUtf8NoBom -Path $InputPath -Rows $inputRows

$currentInputHash = (Get-FileHash -Algorithm SHA256 -Path $InputPath).Hash
if ($currentInputHash -eq $guard.InputHashSha256) {
    Write-Host "OUTCOME:NO_INPUT_CHANGE_DETECTED_STOP" -ForegroundColor Yellow
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

$reportRows = @()
foreach ($row in $inputRows) {
    foreach ($col in $requiredColumns) {
        $value = [string]$row.$col
        if ([string]::IsNullOrWhiteSpace($value)) {
            $reportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLANK"; CurrentValue=$value }
        } elseif ($value -eq "REQUIRED") {
            $reportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="REQUIRED_PLACEHOLDER"; CurrentValue=$value }
        } elseif ($value -like "Blocked:*" -or $value -eq "BLOCKED") {
            $reportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$col; Issue="BLOCKED_PLACEHOLDER"; CurrentValue=$value }
        }
    }
    foreach ($statusCol in $statusColumns) {
        $statusValue = [string]$row.$statusCol
        if ($statusValue -ne "COMPLETE") {
            $reportRows += [pscustomobject]@{ CertifiedID=$row.CertifiedID; EvidenceShellPath=$row.EvidenceShellPath; Field=$statusCol; Issue="STATUS_NOT_COMPLETE"; CurrentValue=$statusValue }
        }
    }
}

Write-CsvUtf8NoBom -Path $ReportPath -Rows $reportRows

$summaryRows = @()
$priority = 1
foreach ($group in ($reportRows | Group-Object CertifiedID | Sort-Object Name)) {
    $rows = @($group.Group)
    $certifiedId = $group.Name
    $shellPath = ($rows | Select-Object -First 1).EvidenceShellPath
    $fields = @($rows | Select-Object -ExpandProperty Field -Unique | Sort-Object)
    $issues = @($rows | Select-Object -ExpandProperty Issue -Unique | Sort-Object)
    $packetPath = Join-Path $PacketRoot "$certifiedId.csv"
    Write-CsvUtf8NoBom -Path $packetPath -Rows $rows
    $summaryRows += [pscustomobject]@{
        Priority=$priority; CertifiedID=$certifiedId; EvidenceShellPath=$shellPath; GapCount=$rows.Count;
        UniqueFieldCount=$fields.Count; UniqueIssueCount=$issues.Count; PacketPath=$packetPath;
        FieldsToFix=($fields -join "; "); IssueTypes=($issues -join "; "); State="OPEN"
    }
    $priority++
}
Write-CsvUtf8NoBom -Path $SummaryPath -Rows $summaryRows

foreach ($row in $valueBankRows) {
    if ([string]$row.CertifiedID -eq [string]$single.CertifiedID -and [string]$row.Field -eq $fieldName) {
        $row.RequiredValue  = [string]$single.RequiredValue
        $row.EvidenceSource = [string]$single.EvidenceSource
        $row.EvidenceNote   = [string]$single.EvidenceNote
        $row.EntryState     = "COMPLETED"
    }
}
Write-CsvUtf8NoBom -Path $ValueBankPath -Rows $valueBankRows

foreach ($row in $submissionStatusRows) {
    if ([string]$row.CertifiedID -eq [string]$single.CertifiedID) { $row.SubmissionState = "UPDATED" }
}
Write-CsvUtf8NoBom -Path $SubmissionStatusPath -Rows $submissionStatusRows

$dashboardGroups = $reportRows | Group-Object CertifiedID
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
Write-CsvUtf8NoBom -Path $BlockerDashboardPath -Rows $blockerDashboardRows

$targetStatusRows = @([pscustomobject]@{
    CertifiedID=[string]$single.CertifiedID; Field=$fieldName; MainInputValue=$newValue;
    RequiredValue=[string]$single.RequiredValue; EvidenceSource=[string]$single.EvidenceSource;
    EvidenceNote=[string]$single.EvidenceNote; State="UPDATED"
})
Write-CsvUtf8NoBom -Path $TargetStatusPath -Rows $targetStatusRows

$deltaRows = @([pscustomobject]@{
    CertifiedID=[string]$single.CertifiedID; Field=$fieldName; SourceValue=[string]$single.SourceValue;
    AppliedValue=[string]$single.RequiredValue; IsDifferent=([string]$single.SourceValue -ne [string]$single.RequiredValue)
})
Write-CsvUtf8NoBom -Path $DeltaPath -Rows $deltaRows

$currentGapCount  = $reportRows.Count
$baselineGapCount = [int]$guard.GapCount
Write-Host ("APPLIED_FIELD:{0}" -f $fieldName) -ForegroundColor Green
Write-Host ("BASELINE_GAP_COUNT:{0}" -f $baselineGapCount) -ForegroundColor Yellow
Write-Host ("CURRENT_GAP_COUNT:{0}" -f $currentGapCount) -ForegroundColor Yellow

if ($currentGapCount -ge $baselineGapCount) {
    Write-Host "OUTCOME:GAP_COUNT_NOT_REDUCED_STOP" -ForegroundColor Yellow
    return
}

$newGuard = [ordered]@{
    BaselineCreatedUtc = [DateTime]::UtcNow.ToString("o")
    InputPath          = $InputPath
    ReportPath         = $ReportPath
    SummaryPath        = $SummaryPath
    PacketRoot         = $PacketRoot
    InputHashSha256    = $currentInputHash
    ReportHashSha256   = (Get-FileHash -Algorithm SHA256 -Path $ReportPath).Hash
    GapCount           = $currentGapCount
    CertifiedIdCount   = $summaryRows.Count
    State              = "PROGRESS_RECORDED"
} | ConvertTo-Json -Depth 6

Write-Utf8NoBom -Path $GuardPath -Text $newGuard
Write-Host "OUTCOME:PROGRESS_RECORDED_GAP_COUNT_REDUCED" -ForegroundColor Green