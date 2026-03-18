Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$global:LASTEXITCODE = 0

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"
    Set-Location $REPO

    $searchRoots = @(
        "C:\Projects\MindLab_Starter_Project\backend\scripts"
    )

    $allFiles = @()

    foreach ($root in $searchRoots) {
        if (Test-Path $root) {
            $allFiles += Get-ChildItem -Path $root -Recurse -File -Include *.cjs,*.mjs,*.js -ErrorAction SilentlyContinue
        }
    }

    $files = $allFiles |
        Where-Object {
            $_.FullName -notmatch '\\node_modules\\' -and
            $_.FullName -notmatch '\\_quarantine\\' -and
            $_.Name -notlike '*.backup.js'
        } |
        Sort-Object FullName -Unique

    if (-not $files) {
        Write-Host "OK: no eligible JS/CJS/MJS files found under backend\scripts" -ForegroundColor Green
        exit 0
    }

    $failed = @()

    foreach ($file in $files) {
        switch -Regex ($file.Extension) {
            '\.cjs$' {
                & node --check $file.FullName
                if ($LASTEXITCODE -ne 0) { $failed += $file.FullName }
            }
            '\.mjs$' {
                & node --check $file.FullName
                if ($LASTEXITCODE -ne 0) { $failed += $file.FullName }
            }
            '\.js$' {
                $content = Get-Content -LiteralPath $file.FullName -Raw
                if ($content -match '^\s*(import|export)\s' -or $content -match "`n\s*(import|export)\s") {
                    Write-Host ("SKIP_ESM_JS: " + $file.FullName) -ForegroundColor Yellow
                    continue
                }

                & node --check $file.FullName
                if ($LASTEXITCODE -ne 0) { $failed += $file.FullName }
            }
        }
    }

    if ($failed.Count -gt 0) {
        $failed | Out-Host
        throw "STOP: node --check failed"
    }

    Write-Host "OK: node --check passed for eligible backend\scripts files" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
