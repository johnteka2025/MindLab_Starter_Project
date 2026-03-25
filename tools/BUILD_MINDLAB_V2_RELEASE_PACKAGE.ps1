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
    $OutDir = "C:\MindLab_Delivery\2026-03-25"
    $ZipPath = "C:\MindLab_Delivery\MindLab_V2_Release_Candidate_2026-03-25.zip"

    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

    $files = @(
        "$Repo\docs\scopes\mindlab_v2_release_candidate_scope_2026_03_25.md",
        "$Repo\release_archive\2026-03-25\mindlab_v2_release_candidate_manifest.txt",
        "$Repo\tools\MINDLAB_V2_DEPLOYMENT_READINESS_CHECK.ps1",
        "$Repo\.env.mindlab_v2.example"
    )

    foreach ($f in $files) {
        if (!(Test-Path $f)) {
            Write-Host "STOP: missing release package file $f" -ForegroundColor Yellow
            exit 1
        }
    }

    Copy-Item -Force $files -Destination $OutDir
    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    Compress-Archive -Path "$OutDir\*" -DestinationPath $ZipPath -Force

    Write-Host "OK: release package built" -ForegroundColor Green
    Write-Host $OutDir -ForegroundColor Cyan
    Write-Host $ZipPath -ForegroundColor Cyan
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
