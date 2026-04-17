Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot             = "C:\Projects\MindLab_Starter_Project"
$ProgressJson         = "C:\Projects\MindLab_Starter_Project\backend\src\data\progress.json"
$SummaryPath          = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\open_bundle_population_summary.txt"
$GapSummaryPath       = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\unresolved_exact_source_gap_summary.txt"
$BlockerSummaryPath   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\machine_patch_blocker_summary.txt"
$BlockerRegisterPath  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\machine_patch_blocker_register.csv"
$ManifestPath         = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\00_control\apply_gate_rollup_2026-04-13\machine_patch_blocker_handoff_manifest_2026-04-17.txt"
$Wave2PatchTemplate   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\08_wave2\kickoff_2026-04-12\wave2_owner_intake_patch_template.csv"
$LegacyPatchTemplate  = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\05_ops_legacy\recertification_2026-04-12\legacy_candidate_approval_patch_template.csv"
$CrossPatchTemplate   = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\10_cross_age\handoff_2026-04-12\cross_age_owner_intake_patch_template.csv"

function Pause-Safe {
    Set-Location $RepoRoot
    Read-Host "Press ENTER to keep PowerShell open for review" | Out-Null
    Set-Location $RepoRoot
}

foreach ($path in @(
    $RepoRoot,
    $ProgressJson,
    $SummaryPath,
    $GapSummaryPath,
    $BlockerSummaryPath,
    $BlockerRegisterPath,
    $ManifestPath,
    $Wave2PatchTemplate,
    $LegacyPatchTemplate,
    $CrossPatchTemplate
)) {
    if (!(Test-Path $path)) { throw "Missing path: $path" }
}

Set-Location $RepoRoot

git -C $RepoRoot restore --source=HEAD --staged --worktree -- "tools\backend.pid" 2>$null
git -C $RepoRoot restore --source=HEAD --staged --worktree -- "backend\src\data\progress.json" 2>$null

$state = @(git -C $RepoRoot status --porcelain)
if ($state.Count -gt 0) {
    Write-Host "RESULT: REPO_DIRTY_STOP" -ForegroundColor Red
    git -C $RepoRoot status --short | Out-Host
    Pause-Safe
    return
}

$summaryText = Get-Content -Path $SummaryPath -Raw

if ($summaryText -match "State=READY") {
    Write-Host "RESULT: READY_FOR_NEXT_HANDOFF" -ForegroundColor Green
} else {
    Write-Host "RESULT: NO_FURTHER_MACHINE_ONLY_TASKS_STOP" -ForegroundColor Yellow
    Write-Host $BlockerRegisterPath
    Write-Host $Wave2PatchTemplate
    Write-Host $LegacyPatchTemplate
    Write-Host $CrossPatchTemplate
    Write-Host $ManifestPath
}

Pause-Safe