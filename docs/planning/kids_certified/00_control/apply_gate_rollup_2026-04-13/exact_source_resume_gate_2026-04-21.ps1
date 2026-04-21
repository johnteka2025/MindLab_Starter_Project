Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot            = "C:\Projects\MindLab_Starter_Project"
$StatusCsv           = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv"
$BlockerCsv          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv"
$IncomingTemplateCsv = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv"

function Pause-Safe {
    Set-Location "C:\Projects\MindLab_Starter_Project"
    Read-Host "Press ENTER after review" | Out-Null
    Set-Location "C:\Projects\MindLab_Starter_Project"
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
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv",
    "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv"
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
$allowedDirty = @(
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.csv",
    "docs/planning/kids_certified/00_control/apply_gate_rollup_2026-04-13/external_approved_values_received_template_2026-04-21.txt"
)
$unexpected = @($dirty | Where-Object { $_.Path -notin $allowedDirty })

if ($unexpected.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    $unexpected | ForEach-Object { Write-Host $_.Path -ForegroundColor Red }
    Pause-Safe
    return
}

$statusRows  = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\final_lane_status_2026-04-21.csv")
$blockerRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\exact_source_blocked_status_2026-04-21.csv")
$incomingRows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\external_approved_values_received_template_2026-04-21.csv")

$approvedRows = @($incomingRows | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })

if (
    [string]$statusRows[0].ExactSourceLaneStatus -ne "BLOCKED_PENDING_REAL_APPROVALS" -or
    [string]$blockerRows[0].BlockStatus -ne "BLOCKED"
) {
    Write-Host "RESULT: STATUS_MISMATCH_STOP" -ForegroundColor Red
    Pause-Safe
    return
}

if ($approvedRows.Count -eq 0) {
    Write-Host "RESULT: WAITING_FOR_EXTERNAL_APPROVED_VALUES_STOP" -ForegroundColor Yellow
    Write-Host "ApprovedRows=0" -ForegroundColor Yellow
    Pause-Safe
    return
}

Write-Host "RESULT: EXTERNAL_APPROVED_VALUES_RECEIVED_READY_FOR_NEXT_LANE" -ForegroundColor Green
Write-Host "ApprovedRows=$($approvedRows.Count)" -ForegroundColor Green
Pause-Safe