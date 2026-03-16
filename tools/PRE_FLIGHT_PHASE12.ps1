Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    Set-Location $REPO

    $critical = @(
        "C:\Projects\MindLab_Starter_Project\.github\workflows\mindlab-ci.yml",
        "C:\Projects\MindLab_Starter_Project\tools\RUN_ALL_GATES.ps1",
        "C:\Projects\MindLab_Starter_Project\tools\MASTER_CONTINUATION_CONTROL.ps1",
        "C:\Projects\MindLab_Starter_Project\tools\EXPORT_RELEASE_PACKAGE.ps1",
        "C:\Projects\MindLab_Starter_Project\tools\CI_RELEASE_AUTOMATION_README.md"
    )

    foreach ($f in $critical) {
        if (!(Test-Path $f)) {
            throw "STOP: missing critical file $f"
        }
    }

    $status = git status --porcelain
    if ($status) {
        $status | Out-Host
        throw "STOP: repository dirty before Phase 12"
    }

    Write-Host "OK: critical files verified" -ForegroundColor Green
    Write-Host "OK: repository clean before Phase 12" -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
