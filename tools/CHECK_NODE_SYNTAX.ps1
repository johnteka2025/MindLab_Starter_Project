Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    Set-Location $REPO

    $files = Get-ChildItem -Path (Join-Path $REPO "backend") -Recurse -Include *.js,*.cjs,*.mjs -File -ErrorAction SilentlyContinue

    if (-not $files) {
        Write-Host "OK: no JS/CJS/MJS files found under backend" -ForegroundColor Green
        return
    }

    $failed = @()

    foreach ($file in $files) {
        & node --check $file.FullName
        if ($LASTEXITCODE -ne 0) {
            $failed += $file.FullName
        }
    }

    if ($failed.Count -gt 0) {
        $failed | Out-Host
        throw "STOP: node --check failed"
    }

    Write-Host "OK: node --check passed for backend scripts" -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
