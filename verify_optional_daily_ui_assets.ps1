# verify_optional_daily_ui_assets.ps1
# Just reports which optional daily UI files/scripts exist

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"

$items = @(
    @{ Label = "Spec file"; Path = "frontend\tests\e2e\mindlab-daily-ui-optional.spec.ts" },
    @{ Label = "Writer script"; Path = "write_daily_ui_optional_spec.ps1" },
    @{ Label = "Runner script"; Path = "run_daily_ui_optional_test.ps1" },
    @{ Label = "Orchestrator script"; Path = "expand_daily_ui_optional_coverage.ps1" }
)

Write-Host "== Optional Daily UI Assets =="

foreach ($item in $items) {
    $full = Join-Path $projectRoot $item.Path
    if (Test-Path $full) {
        Write-Host ("[OK] {0}: {1}" -f $item.Label, $full) -ForegroundColor Green
    } else {
        Write-Host ("[MISS] {0}: {1}" -f $item.Label, $full) -ForegroundColor Yellow
    }
}

exit 0
