param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    Set-Location $Repo

    $required = @(
        "$Repo\backend\scripts\phase18_scope_placeholder.cjs",
        "$Repo\backend\scripts\phase18_scope_contract.cjs",
        "$Repo\backend\scripts\phase18_pipeline_controller.cjs",
        "$Repo\backend\scripts\phase18_state_snapshot_manager.cjs",
        "$Repo\backend\scripts\phase18_result_formatter.cjs"
    )

    foreach ($file in $required) {
        if (!(Test-Path $file)) {
            throw "STOP: missing critical file $file"
        }
    }

    $status = git status --porcelain
    if ($status) {
        Write-Host "STOP: repository not clean before Phase 12" -ForegroundColor Yellow
        $status | Out-Host
        Complete-Step -Code 2 -Message "STOP: repository not clean before Phase 12"
        return
    }

    Write-Host "OK: critical files verified" -ForegroundColor Green
    Complete-Step -Code 0 -Message "OK: repository clean before Phase 12"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
