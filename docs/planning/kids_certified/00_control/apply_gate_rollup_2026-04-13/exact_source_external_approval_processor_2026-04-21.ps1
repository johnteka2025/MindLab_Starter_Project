Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot            = "C:\Projects\MindLab_Starter_Project"
$ProgressJson        = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$ExternalSourceCsv   = "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv"
$TemplateCsv         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv"
$TemplateTxt         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.txt"
$IntakeCsv           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv"
$ReadyImportCsv      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv"
$ReadyImportTxt      = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.txt"

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
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv"
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

$dirty = @(Get-DirtyEntries -Root "C:\Projects\MindLab_Starter_Project")
if ($dirty.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    $dirty | ForEach-Object { Write-Host $_.Path -ForegroundColor Red }
    Pause-Safe
    return
}

$incomingRows = @(Import-Csv -Path "C:\Projects\MindLab_External_Input\wave2_exact_source_external_approved_values.csv")
$approvedRows = @($incomingRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })

if ($approvedRows.Count -eq 0) {
    Write-Host "RESULT: WAITING_FOR_EXTERNAL_APPROVED_VALUES_STOP" -ForegroundColor Yellow
    Write-Host "ApprovedRows=0" -ForegroundColor Yellow
    Pause-Safe
    return
}

$invalidRows = @($approvedRows | Where-Object {
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

$templateRows = @($approvedRows | ForEach-Object {
    [pscustomobject]@{
        LaneName          = "Wave2_SignoffCheckpoint_ExactSource"
        ItemKey           = [string]$_.ItemKey
        FieldName         = [string]$_.FieldName
        ApprovedNewValue  = [string]$_.ApprovedNewValue
        ApprovalSource    = [string]$_.ApprovalSource
        ApprovedBy        = [string]$_.ApprovedBy
        ApprovedDate      = [string]$_.ApprovedDate
        EvidenceReference = [string]$_.EvidenceReference
        Notes             = "Imported from external approved values source"
    }
})
Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv" -Rows $templateRows
Write-TextUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.txt" -Lines @(
    "RESULT: EXTERNAL_APPROVED_VALUES_FILE_READY",
    "ApprovedRows=$($templateRows.Count)"
)

$intakeRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_approved_value_intake_2026-04-18.csv")
$readyRows = foreach ($row in $templateRows) {
    $match = $intakeRows | Where-Object {
        (
            ($_.PSObject.Properties.Name -contains "ItemKey") -and
            ($_.PSObject.Properties.Name -contains "FieldName") -and
            ([string]$_.ItemKey -eq [string]$row.ItemKey) -and
            ([string]$_.FieldName -eq [string]$row.FieldName)
        ) -or (
            ($_.PSObject.Properties.Name -contains "ItemKey") -and
            -not ($_.PSObject.Properties.Name -contains "FieldName") -and
            ([string]$_.ItemKey -eq [string]$row.ItemKey)
        ) -or (
            -not ($_.PSObject.Properties.Name -contains "ItemKey") -and
            ($_.PSObject.Properties.Name -contains "FieldName") -and
            ([string]$_.FieldName -eq [string]$row.FieldName)
        )
    } | Select-Object -First 1

    [pscustomobject]@{
        LaneName          = [string]$row.LaneName
        ItemKey           = [string]$row.ItemKey
        FieldName         = [string]$row.FieldName
        ApprovedNewValue  = [string]$row.ApprovedNewValue
        ApprovalSource    = [string]$row.ApprovalSource
        ApprovedBy        = [string]$row.ApprovedBy
        ApprovedDate      = [string]$row.ApprovedDate
        EvidenceReference = [string]$row.EvidenceReference
        IntakeMatched     = if ($null -ne $match) { "Y" } else { "N" }
    }
}
Write-CsvUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv" -Rows $readyRows
Write-TextUtf8NoBom -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.txt" -Lines @(
    "RESULT: EXACT_SOURCE_READY_IMPORT_CREATED",
    "ApprovedRows=$($readyRows.Count)"
)

git -C "C:\Projects\MindLab_Starter_Project" add -- `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.txt" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.csv" `
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/wave2_signoffcheckpoint_ready_import_2026-04-21.txt"

$staged = @(git -C "C:\Projects\MindLab_Starter_Project" diff --cached --name-only)
if ($staged.Count -eq 0) {
    Write-Host "RESULT: NOTHING_TO_COMMIT_STOP" -ForegroundColor Yellow
    Pause-Safe
    return
}

git -C "C:\Projects\MindLab_Starter_Project" commit -m "Process external approved values and create Wave2 ready import"
if ($LASTEXITCODE -ne 0) {
    Write-Host "RESULT: COMMIT_FAILURE_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

Write-Host "RESULT: COMMIT_SUCCESS" -ForegroundColor Green
git -C "C:\Projects\MindLab_Starter_Project" show --stat --oneline -1
Write-Host "RESULT: EXTERNAL_APPROVED_VALUES_RECEIVED_READY_FOR_NEXT_LANE" -ForegroundColor Green

Pause-Safe