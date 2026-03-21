param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    $pidFile = "C:\Projects\MindLab_Starter_Project\tools\backend.pid"

    if (Test-Path $pidFile) {
        $raw = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($raw -match '^\d+$') {
            $pidValue = [int]$raw
            $proc = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
            if ($proc) {
                Stop-Process -Id $pidValue -Force
                Start-Sleep -Seconds 2
            }
        }
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }

    $nodeProcs = Get-CimInstance Win32_Process | Where-Object {
        $_.Name -match '^node(\.exe)?$' -and $_.CommandLine -match 'MindLab_Starter_Project'
    }

    foreach ($proc in $nodeProcs) {
        try { Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop } catch {}
    }

    Write-Host "OK: backend stop routine completed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    if (-not $NoPause) {
        Read-Host "Press ENTER (PowerShell stays open)"
    }
}
