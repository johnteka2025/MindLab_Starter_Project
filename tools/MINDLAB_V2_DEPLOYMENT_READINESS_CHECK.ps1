param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Wait-ForUser {
    Write-Host ""
    Read-Host "Press ENTER (PowerShell stays open)"
}

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"

    $required = @(
        "$Repo\frontend\src\ui\mindlab_v2_analytics_dashboard.js",
        "$Repo\frontend\src\ui\mindlab_v2_learner_analytics_trends.js",
        "$Repo\frontend\src\ui\mindlab_v2_admin_educator_test.js",
        "$Repo\backend\src\game\mindlab_v2_persistence_service.js",
        "$Repo\backend\src\game\mindlab_v2_route_registry.js"
    )

    foreach ($file in $required) {
        if (!(Test-Path $file)) {
            Write-Host "STOP: missing required deployment file $file" -ForegroundColor Yellow
            exit 1
        }
    }

    Write-Host "OK: deployment readiness basic file check passed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
