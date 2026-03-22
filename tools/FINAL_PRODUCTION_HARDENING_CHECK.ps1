param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    Set-Location $Repo

    $requiredFiles = @(
        "$Repo\game\achievements_engine.js",
        "$Repo\game\tournament_engine.js",
        "$Repo\game\puzzle_editor_engine.js",
        "$Repo\game\live_ops_engine.js",
        "$Repo\game\analytics_engine.js",
        "$Repo\game\content_pack_engine.js",
        "$Repo\game\qa_automation_engine.js",
        "$Repo\release_archive\2026-03-23\version2_planning_scope.txt",
        "$Repo\release_archive\2026-03-23\version2_reusable_modules.txt",
        "$Repo\release_archive\2026-03-23\version2_refactor_candidates.txt",
        "$Repo\release_archive\2026-03-23\version2_roadmap.txt"
    )

    foreach ($file in $requiredFiles) {
        if (!(Test-Path $file)) {
            throw "STOP: missing critical file $file"
        }
    }

    Complete-Step -Code 0 -Message "OK: final production hardening file verification passed"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
