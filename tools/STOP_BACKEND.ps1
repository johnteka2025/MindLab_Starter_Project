Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $pidFile = "C:\Projects\MindLab_Starter_Project\tools\backend.pid"
    Set-Location "C:\"

    if (Test-Path $pidFile) {
        $rawPid = (Get-Content -LiteralPath $pidFile -Raw).Trim()

        if ($rawPid -match '^\d+$') {
            $proc = Get-Process -Id ([int]$rawPid) -ErrorAction SilentlyContinue
            if ($proc) {
                Stop-Process -Id ([int]$rawPid) -Force -ErrorAction Stop
                Write-Host "OK: backend stopped PID=$rawPid" -ForegroundColor Green
            }
            else {
                Write-Host "OK: backend already stopped" -ForegroundColor Green
            }
        }
        else {
            Write-Host "OK: backend already stopped" -ForegroundColor Green
        }

        Set-Content -Path $pidFile -Value "" -Encoding ASCII
        exit 0
    }

    Write-Host "OK: backend already stopped" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
