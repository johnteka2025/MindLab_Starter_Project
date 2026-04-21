Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot       = "C:\Projects\MindLab_Starter_Project"
$ProgressJson   = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$ReadyImportCsv = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv"

function Pause-Safe {
    Set-Location "C:\Projects\MindLab_Starter_Project"
    Read-Host "Press ENTER after review" | Out-Null
    Set-Location "C:\Projects\MindLab_Starter_Project"
}

foreach ($path in @(
    "C:\Projects\MindLab_Starter_Project",
    "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
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

if (!(Test-Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv")) {
    Write-Host "RESULT: DOWNSTREAM_HARD_BLOCK_STOP" -ForegroundColor Red
    Write-Host "Reason=READY_IMPORT_MISSING" -ForegroundColor Red
    Pause-Safe
    return
}

$rows = @(Import-Csv -Path "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\wave2_signoffcheckpoint_ready_import_2026-04-21.csv" |
    Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.ApprovedNewValue) })

if ($rows.Count -eq 0) {
    Write-Host "RESULT: DOWNSTREAM_HARD_BLOCK_STOP" -ForegroundColor Red
    Write-Host "Reason=READY_IMPORT_EMPTY" -ForegroundColor Red
    Pause-Safe
    return
}

Write-Host "RESULT: DOWNSTREAM_GATE_OPEN" -ForegroundColor Green
Write-Host "ApprovedRows=$($rows.Count)" -ForegroundColor Green
Pause-Safe