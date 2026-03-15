Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"
    $DEST = "C:\MindLab_Release_Export\2026-03-15"
    $ZIP  = "C:\MindLab_Release_Export\MindLab_Release_Export_2026-03-15.zip"

    New-Item -ItemType Directory -Force -Path $DEST | Out-Null

    $files = @(
        "C:\Projects\MindLab_Starter_Project\tools\RUN_ALL_GATES.ps1",
        "C:\Projects\MindLab_Starter_Project\tools\MASTER_CONTINUATION_CONTROL.ps1",
        "C:\Projects\MindLab_Starter_Project\release_archive\2026-03-13\archival_handoff_manifest.txt",
        "C:\Projects\MindLab_Starter_Project\release_archive\2026-03-13\master_control_validation.txt",
        "C:\Projects\MindLab_Starter_Project\release_archive\2026-03-14\latest_commit.txt",
        "C:\Projects\MindLab_Starter_Project\release_archive\2026-03-14\repo_state.txt",
        "C:\Projects\MindLab_Starter_Project\release_archive\2026-03-14\branch_state.txt"
    )

    foreach ($file in $files) {
        if (!(Test-Path $file)) {
            throw "Missing required export file: $file"
        }
        Copy-Item -Path $file -Destination $DEST -Force
    }

    if (Test-Path $ZIP) {
        Remove-Item $ZIP -Force -ErrorAction SilentlyContinue
    }

    Compress-Archive -Path "$DEST\*" -DestinationPath $ZIP -Force

    if (!(Test-Path $ZIP)) {
        throw "Release export zip not created"
    }

    Write-Host "OK: release export created" -ForegroundColor Green
    Write-Host $ZIP
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
