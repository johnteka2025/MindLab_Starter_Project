Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $repo    = "C:\Projects\MindLab_Starter_Project"
    $logs    = "C:\Projects\MindLab_Starter_Project\tools\logs"
    $pidFile = "C:\Projects\MindLab_Starter_Project\tools\backend.pid"

    New-Item -ItemType Directory -Force -Path $logs | Out-Null
    Set-Location $repo

    $stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
    $outLog = Join-Path $logs ("backend_dev_" + $stamp + ".out.log")
    $errLog = Join-Path $logs ("backend_dev_" + $stamp + ".err.log")

    $entryCandidates = @(
        "C:\Projects\MindLab_Starter_Project\backend\server.js",
        "C:\Projects\MindLab_Starter_Project\backend\app.js",
        "C:\Projects\MindLab_Starter_Project\backend\index.js",
        "C:\Projects\MindLab_Starter_Project\backend\src\server.js",
        "C:\Projects\MindLab_Starter_Project\server.js"
    )

    $entry = $entryCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $entry) {
        throw "STOP: backend entry file not found"
    }

    if (Test-Path $pidFile) {
        $existingPid = (Get-Content -LiteralPath $pidFile -Raw).Trim()
        if ($existingPid -match '^\d+$') {
            $proc = Get-Process -Id ([int]$existingPid) -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "OK: backend already running PID=$existingPid" -ForegroundColor Green
                exit 0
            }
        }
    }

    $proc = Start-Process -FilePath "node" -ArgumentList @($entry) -WorkingDirectory $repo -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru

    if (-not $proc) {
        throw "STOP: backend failed to start"
    }

    Start-Sleep -Seconds 5

    if ($proc.HasExited) {
        if (Test-Path $errLog) {
            Get-Content -LiteralPath $errLog -Tail 120 -ErrorAction SilentlyContinue | Out-Host
        }
        throw "STOP: backend exited immediately"
    }

    Set-Content -Path $pidFile -Value $proc.Id -Encoding ASCII

    Write-Host "OK: backend started PID=$($proc.Id)" -ForegroundColor Green
    Write-Host "OUT_LOG=$outLog"
    Write-Host "ERR_LOG=$errLog"
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
