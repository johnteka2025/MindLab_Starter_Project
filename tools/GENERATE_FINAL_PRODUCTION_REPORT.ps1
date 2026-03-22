param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    $report = "$Repo\release_archive\2026-03-23\final_production_hardening_report.txt"
    New-Item -ItemType Directory -Force -Path (Split-Path $report -Parent) | Out-Null

    $branch = git -C $Repo branch --show-current
    $head = git -C $Repo rev-parse HEAD
    $status = git -C $Repo status --porcelain

    @"
FINAL PRODUCTION HARDENING REPORT
DATE=2026-03-23
BRANCH=$branch
HEAD=$head
REPO_STATUS=$(if ($status) { "DIRTY" } else { "CLEAN" })
TRACKS_COMPLETED
- achievements
- tournament
- puzzle editor
- live ops
- analytics
- content pack pipeline
- QA automation
- version 2 planning
"@ | Set-Content -Path $report -Encoding UTF8

    if (!(Test-Path $report)) {
        throw "STOP: final production hardening report creation failed"
    }

    Complete-Step -Code 0 -Message "OK: final production hardening report generated"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
