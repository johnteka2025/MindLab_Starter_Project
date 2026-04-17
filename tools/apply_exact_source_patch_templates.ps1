Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot                  = "C:\Projects\MindLab_Starter_Project"
$ProgressJson              = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$ExactPathIntake           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\tracker_refresh_2026-04-12\tracker_manual_exact_path_intake.csv"
$ApplySnapshotsRoot        = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_snapshots_2026-04-14"
$ReleaseAttachmentsRoot    = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\07_release\evidence_bundle_2026-04-12\attachments"
$Snapshots99Root           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\99_snapshots"

$ReleaseSourceInv          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\07_release\evidence_bundle_2026-04-12\release_evidence_source_inventory.csv"
$ReleaseOutputPop          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\07_release\evidence_bundle_2026-04-12\release_output_path_population.csv"

$Wave2OwnerIntake          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\08_wave2\kickoff_2026-04-12\wave2_owner_intake.csv"
$Wave2PatchTemplate        = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\08_wave2\kickoff_2026-04-12\wave2_owner_intake_patch_template.csv"

$LegacyApprovalIntake      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\05_ops_legacy\recertification_2026-04-12\legacy_candidate_approval_intake.csv"
$LegacyPatchTemplate       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\05_ops_legacy\recertification_2026-04-12\legacy_candidate_approval_patch_template.csv"

$CrossAgeOwnerIntake       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\10_cross_age\handoff_2026-04-12\cross_age_owner_intake.csv"
$CrossAgePatchTemplate     = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\10_cross_age\handoff_2026-04-12\cross_age_owner_intake_patch_template.csv"

$AuditPath                 = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\open_bundle_population_audit.csv"
$SummaryPath               = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\open_bundle_population_summary.txt"
$GapRegisterPath           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\unresolved_exact_source_gap_register.csv"
$GapSummaryPath            = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\unresolved_exact_source_gap_summary.txt"

$BackupRoot                = "C:\Temp\MindLab_Session\patch_apply_backups"

function Pause-Safe {
    Set-Location $RepoRoot
    Read-Host "Press ENTER to keep PowerShell open for review" | Out-Null
    Set-Location $RepoRoot
}

function Ensure-TrackedFileFromHead {
    param([string]$RepoRelativePath,[string]$AbsolutePath)
    if (Test-Path $AbsolutePath) { return }
    git -C $RepoRoot ls-files --error-unmatch -- "$RepoRelativePath" *> $null
    if ($LASTEXITCODE -ne 0) { throw "Tracked file not found in git index: $RepoRelativePath" }
    $parent = Split-Path -Parent $AbsolutePath
    if ($parent -and !(Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    git -C $RepoRoot restore --source=HEAD --staged --worktree -- "$RepoRelativePath"
    if (!(Test-Path $AbsolutePath)) { throw "Failed to recreate tracked file from HEAD: $AbsolutePath" }
}

function Write-Utf8NoBom {
    param([string]$Path,[string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path,$Text,(New-Object System.Text.UTF8Encoding($false)))
}

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (@($Rows).Count -eq 0) {
        [System.IO.File]::WriteAllText($Path,"",(New-Object System.Text.UTF8Encoding($false)))
        return
    }
    $csv = @($Rows) | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path,$csv,(New-Object System.Text.UTF8Encoding($false)))
}

function Import-CsvSafe {
    param([string]$Path)
    if (!(Test-Path $Path)) { return @() }
    $raw = Get-Content -Path $Path -ErrorAction Stop
    if (@($raw).Count -le 1) { return @() }
    return @(Import-Csv -Path $Path)
}

function Is-Placeholder {
    param([object]$Value)
    $s = [string]$Value
    if ([string]::IsNullOrWhiteSpace($s)) { return $true }
    return @("TBD","PENDING","NA","N/A","NULL") -contains $s.Trim().ToUpperInvariant()
}

function Get-RowValue {
    param([object]$Row,[string]$ColumnName)
    if ($null -eq $Row) { return $null }
    if ($Row.PSObject.Properties.Name -contains $ColumnName) { return $Row.$ColumnName }
    return $null
}

function Set-RowValue {
    param([object]$Row,[string]$ColumnName,[object]$Value)
    if ($Row.PSObject.Properties.Name -contains $ColumnName) {
        $Row.$ColumnName = $Value
    } else {
        Add-Member -InputObject $Row -MemberType NoteProperty -Name $ColumnName -Value $Value
    }
}

function Backup-File {
    param([string]$Path)
    if (!(Test-Path $Path)) { return }
    if (!(Test-Path $BackupRoot)) { New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null }
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $ext      = [System.IO.Path]::GetExtension($Path)
    $stamp    = Get-Date -Format "yyyyMMdd_HHmmss"
    $dest     = Join-Path $BackupRoot ($baseName + "_" + $stamp + $ext + ".bak")
    Copy-Item -LiteralPath $Path -Destination $dest -Force
}

function Apply-PatchTemplate {
    param(
        [object[]]$TargetRows,
        [string]$KeyField,
        [object[]]$PatchRows
    )

    $applied = 0
    $nonBlankPatchValues = 0

    foreach ($patchRow in @($PatchRows)) {
        $keyValue = [string](Get-RowValue -Row $patchRow -ColumnName $KeyField)
        if ([string]::IsNullOrWhiteSpace($keyValue)) { continue }

        $targetRow = $null
        foreach ($candidate in @($TargetRows)) {
            if ([string](Get-RowValue -Row $candidate -ColumnName $KeyField) -eq $keyValue) {
                $targetRow = $candidate
                break
            }
        }

        if ($null -eq $targetRow) { continue }

        foreach ($property in $patchRow.PSObject.Properties.Name) {
            if ($property -eq $KeyField) { continue }

            $patchValue = Get-RowValue -Row $patchRow -ColumnName $property
            if (Is-Placeholder -Value $patchValue) { continue }

            $nonBlankPatchValues++
            $currentValue = Get-RowValue -Row $targetRow -ColumnName $property

            if ([string]$currentValue -ne [string]$patchValue) {
                Set-RowValue -Row $targetRow -ColumnName $property -Value ([string]$patchValue)
                $applied++
            }
        }
    }

    return [pscustomobject]@{
        AppliedChanges = $applied
        NonBlankPatchValues = $nonBlankPatchValues
    }
}

function Get-GitStatusLines {
    return @(git -C $RepoRoot status --porcelain)
}

function Get-StatusRelativePath {
    param([string]$Line)
    return (($Line -replace '^[ MARCUD\?]{2}\s+', '').Replace('\','/'))
}

function Get-DirtyOutsideAllowedPaths {
    param([string[]]$AllowedRepoRelative)
    $outside = @()
    foreach ($line in @(Get-GitStatusLines)) {
        $rel = Get-StatusRelativePath -Line $line
        if ($AllowedRepoRelative -notcontains $rel) { $outside += $line }
    }
    return @($outside)
}

$TrackedFiles = @(
    @{ Rel = "backend/src/data/progress.json"; Abs = $ProgressJson },
    @{ Rel = "docs/planning/kids_certified/00_control/tracker_refresh_2026-04-12/tracker_manual_exact_path_intake.csv"; Abs = $ExactPathIntake },
    @{ Rel = "docs/planning/kids_certified/07_release/evidence_bundle_2026-04-12/release_evidence_source_inventory.csv"; Abs = $ReleaseSourceInv },
    @{ Rel = "docs/planning/kids_certified/07_release/evidence_bundle_2026-04-12/release_output_path_population.csv"; Abs = $ReleaseOutputPop },
    @{ Rel = "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake.csv"; Abs = $Wave2OwnerIntake },
    @{ Rel = "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake_patch_template.csv"; Abs = $Wave2PatchTemplate },
    @{ Rel = "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_intake.csv"; Abs = $LegacyApprovalIntake },
    @{ Rel = "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_patch_template.csv"; Abs = $LegacyPatchTemplate },
    @{ Rel = "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake.csv"; Abs = $CrossAgeOwnerIntake },
    @{ Rel = "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake_patch_template.csv"; Abs = $CrossAgePatchTemplate },
    @{ Rel = "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_audit.csv"; Abs = $AuditPath },
    @{ Rel = "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_summary.txt"; Abs = $SummaryPath },
    @{ Rel = "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_register.csv"; Abs = $GapRegisterPath },
    @{ Rel = "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_summary.txt"; Abs = $GapSummaryPath }
)

foreach ($item in $TrackedFiles) {
    Ensure-TrackedFileFromHead -RepoRelativePath $item.Rel -AbsolutePath $item.Abs
}

$AllowedRepoRelative = @(
    "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake.csv",
    "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake_patch_template.csv",
    "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_intake.csv",
    "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_patch_template.csv",
    "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake.csv",
    "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake_patch_template.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_audit.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_summary.txt",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_register.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_summary.txt"
)

Set-Location $RepoRoot

git -C $RepoRoot restore --source=HEAD --staged --worktree -- "tools\backend.pid" 2>$null
git -C $RepoRoot restore --source=HEAD --staged --worktree -- "backend\src\data\progress.json" 2>$null
git -C $RepoRoot restore --source=HEAD --staged --worktree -- "docs\planning\kids_certified\00_control\tracker_refresh_2026-04-12\tracker_manual_exact_path_intake.csv" 2>$null

if (Test-Path $ApplySnapshotsRoot)     { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\00_control\apply_snapshots_2026-04-14" | Out-Host }
if (Test-Path $ReleaseAttachmentsRoot) { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\07_release\evidence_bundle_2026-04-12\attachments" | Out-Host }
if (Test-Path $Snapshots99Root)        { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\99_snapshots" | Out-Host }

$outsideDirty = @(Get-DirtyOutsideAllowedPaths -AllowedRepoRelative $AllowedRepoRelative)
if ($outsideDirty.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    $outsideDirty | Out-Host
    Pause-Safe
    return
}

$wave2TargetRows  = @(Import-CsvSafe -Path $Wave2OwnerIntake)
$wave2PatchRows   = @(Import-CsvSafe -Path $Wave2PatchTemplate)

$legacyTargetRows = @(Import-CsvSafe -Path $LegacyApprovalIntake)
$legacyPatchRows  = @(Import-CsvSafe -Path $LegacyPatchTemplate)

$crossTargetRows  = @(Import-CsvSafe -Path $CrossAgeOwnerIntake)
$crossPatchRows   = @(Import-CsvSafe -Path $CrossAgePatchTemplate)

Backup-File -Path $Wave2OwnerIntake
Backup-File -Path $LegacyApprovalIntake
Backup-File -Path $CrossAgeOwnerIntake
Backup-File -Path $AuditPath
Backup-File -Path $SummaryPath
Backup-File -Path $GapRegisterPath
Backup-File -Path $GapSummaryPath

$wave2Result  = Apply-PatchTemplate -TargetRows $wave2TargetRows  -KeyField "BatchID"        -PatchRows $wave2PatchRows
$legacyResult = Apply-PatchTemplate -TargetRows $legacyTargetRows -KeyField "LegacyID"       -PatchRows $legacyPatchRows
$crossResult  = Apply-PatchTemplate -TargetRows $crossTargetRows  -KeyField "TargetAgeGroup" -PatchRows $crossPatchRows

$totalNonBlankPatchValues = $wave2Result.NonBlankPatchValues + $legacyResult.NonBlankPatchValues + $crossResult.NonBlankPatchValues
$totalAppliedChanges      = $wave2Result.AppliedChanges + $legacyResult.AppliedChanges + $crossResult.AppliedChanges

if ($wave2Result.AppliedChanges -gt 0)  { Write-CsvUtf8NoBom -Path $Wave2OwnerIntake -Rows $wave2TargetRows }
if ($legacyResult.AppliedChanges -gt 0) { Write-CsvUtf8NoBom -Path $LegacyApprovalIntake -Rows $legacyTargetRows }
if ($crossResult.AppliedChanges -gt 0)  { Write-CsvUtf8NoBom -Path $CrossAgeOwnerIntake -Rows $crossTargetRows }

$auditRows = @()
$gapRows   = @()

foreach ($row in @(Import-CsvSafe -Path $Wave2OwnerIntake)) {
    $missing = @()
    foreach ($f in "OwnerName","OwnerEmail","ApproverName","ApproverEmail","QaReviewer","SignoffCheckpoint") {
        if (Is-Placeholder -Value (Get-RowValue -Row $row -ColumnName $f)) { $missing += $f }
    }
    $status = if ($missing.Count -eq 0) { "COMPLETE" } else { "INCOMPLETE" }
    $auditRows += [pscustomobject]@{ Area="Wave2"; Item=$row.BatchID; MissingFields=($missing -join ";"); Status=$status }
    if ($missing.Count -gt 0) {
        $gapRows += [pscustomobject]@{
            Area="Wave2"; Item=$row.BatchID; MissingFields=($missing -join ";")
            PrimarySourceFile=$Wave2OwnerIntake
            PatchTemplateFile=$Wave2PatchTemplate
        }
    }
}

foreach ($row in @(Import-CsvSafe -Path $LegacyApprovalIntake)) {
    $missing = @()
    foreach ($f in "ProposedTarget","Approver","MappingApproved","RewriteRequired") {
        if (Is-Placeholder -Value (Get-RowValue -Row $row -ColumnName $f)) { $missing += $f }
    }
    $status = if ($missing.Count -eq 0) { "COMPLETE" } else { "INCOMPLETE" }
    $auditRows += [pscustomobject]@{ Area="Legacy"; Item=$row.LegacyID; MissingFields=($missing -join ";"); Status=$status }
    if ($missing.Count -gt 0) {
        $gapRows += [pscustomobject]@{
            Area="Legacy"; Item=$row.LegacyID; MissingFields=($missing -join ";")
            PrimarySourceFile=$LegacyApprovalIntake
            PatchTemplateFile=$LegacyPatchTemplate
        }
    }
}

foreach ($row in @(Import-CsvSafe -Path $CrossAgeOwnerIntake)) {
    $missing = @()
    foreach ($f in "OwnerName","OwnerEmail","DependencyReviewer") {
        if (Is-Placeholder -Value (Get-RowValue -Row $row -ColumnName $f)) { $missing += $f }
    }
    $status = if ($missing.Count -eq 0) { "COMPLETE" } else { "INCOMPLETE" }
    $auditRows += [pscustomobject]@{ Area="CrossAge"; Item=$row.TargetAgeGroup; MissingFields=($missing -join ";"); Status=$status }
    if ($missing.Count -gt 0) {
        $gapRows += [pscustomobject]@{
            Area="CrossAge"; Item=$row.TargetAgeGroup; MissingFields=($missing -join ";")
            PrimarySourceFile=$CrossAgeOwnerIntake
            PatchTemplateFile=$CrossAgePatchTemplate
        }
    }
}

foreach ($row in @(Import-CsvSafe -Path $ReleaseSourceInv)) {
    $missing = @()
    foreach ($f in "EvidenceItem","SourcePath","SourceStatus") {
        if (Is-Placeholder -Value (Get-RowValue -Row $row -ColumnName $f)) { $missing += $f }
    }
    $auditRows += [pscustomobject]@{
        Area="ReleaseSource"; Item=$row.EvidenceItem; MissingFields=($missing -join ";")
        Status=$(if ($missing.Count -eq 0 -and $row.SourceStatus -eq "READY") { "COMPLETE" } else { "INCOMPLETE" })
    }
}

foreach ($row in @(Import-CsvSafe -Path $ReleaseOutputPop)) {
    $missing = @()
    foreach ($f in "EvidenceItem","OutputPath") {
        if (Is-Placeholder -Value (Get-RowValue -Row $row -ColumnName $f)) { $missing += $f }
    }
    $auditRows += [pscustomobject]@{
        Area="ReleaseOutput"; Item=$row.EvidenceItem; MissingFields=($missing -join ";")
        Status=$(if ($missing.Count -eq 0) { "COMPLETE" } else { "INCOMPLETE" })
    }
}

$complete = @($auditRows | Where-Object { $_.Status -eq "COMPLETE" }).Count
$incomplete = @($auditRows | Where-Object { $_.Status -ne "COMPLETE" }).Count

$summaryText = "CompleteRows=$complete`nIncompleteRows=$incomplete`nState=" + $(if ($incomplete -eq 0) { "READY" } else { "NOT_READY" })
$gapSummaryText = "Wave2OpenRows=" + @($gapRows | Where-Object { $_.Area -eq 'Wave2' }).Count + "`nLegacyOpenRows=" + @($gapRows | Where-Object { $_.Area -eq 'Legacy' }).Count + "`nCrossAgeOpenRows=" + @($gapRows | Where-Object { $_.Area -eq 'CrossAge' }).Count + "`nGapRegister=" + $GapRegisterPath

Write-CsvUtf8NoBom -Path $AuditPath -Rows $auditRows
Write-Utf8NoBom   -Path $SummaryPath -Text $summaryText
Write-CsvUtf8NoBom -Path $GapRegisterPath -Rows $gapRows
Write-Utf8NoBom   -Path $GapSummaryPath -Text $gapSummaryText

git -C $RepoRoot add -- `
  "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake.csv" `
  "docs/planning/kids_certified/08_wave2/kickoff_2026-04-12/wave2_owner_intake_patch_template.csv" `
  "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_intake.csv" `
  "docs/planning/kids_certified/05_ops_legacy/recertification_2026-04-12/legacy_candidate_approval_patch_template.csv" `
  "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake.csv" `
  "docs/planning/kids_certified/10_cross_age/handoff_2026-04-12/cross_age_owner_intake_patch_template.csv" `
  "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_audit.csv" `
  "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/open_bundle_population_summary.txt" `
  "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_register.csv" `
  "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/unresolved_exact_source_gap_summary.txt"

$staged = @(git -C $RepoRoot diff --cached --name-only)

if ($staged.Count -eq 0) {
    if ($incomplete -eq 0) {
        Write-Host "RESULT: READY_NO_COMMIT_STOP" -ForegroundColor Green
    } elseif ($totalNonBlankPatchValues -eq 0) {
        Write-Host "RESULT: PATCH_VALUES_STILL_BLANK_STOP" -ForegroundColor Yellow
    } else {
        Write-Host "RESULT: NOTHING_STAGED_AND_GAPS_REMAIN" -ForegroundColor Yellow
    }
    Pause-Safe
    return
}

$commitMessage = if ($totalAppliedChanges -gt 0) {
    "docs(kids): apply exact-source patch templates and refresh downstream audit"
} else {
    "docs(kids): refresh exact-source patch state and gap register"
}

git -C $RepoRoot commit -m $commitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Host "RESULT: COMMIT_FAILED_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

git -C $RepoRoot restore --source=HEAD --staged --worktree -- "tools\backend.pid" 2>$null
git -C $RepoRoot restore --source=HEAD --staged --worktree -- "backend\src\data\progress.json" 2>$null
git -C $RepoRoot restore --source=HEAD --staged --worktree -- "docs\planning\kids_certified\00_control\tracker_refresh_2026-04-12\tracker_manual_exact_path_intake.csv" 2>$null

if (Test-Path $ApplySnapshotsRoot)     { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\00_control\apply_snapshots_2026-04-14" | Out-Host }
if (Test-Path $ReleaseAttachmentsRoot) { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\07_release\evidence_bundle_2026-04-12\attachments" | Out-Host }
if (Test-Path $Snapshots99Root)        { git -C $RepoRoot clean -fd -- "docs\planning\kids_certified\99_snapshots" | Out-Host }

$finalState = @(git -C $RepoRoot status --porcelain)
if ($finalState.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    git -C $RepoRoot status --short | Out-Host
    Pause-Safe
    return
}

if ($summaryText -match "State=READY") {
    Write-Host "RESULT: PATCH_APPLY_COMMITTED_READY_FOR_HANDOFF" -ForegroundColor Green
} else {
    Write-Host "RESULT: PATCH_APPLY_COMMITTED_GAPS_REMAIN" -ForegroundColor Yellow
}

Pause-Safe