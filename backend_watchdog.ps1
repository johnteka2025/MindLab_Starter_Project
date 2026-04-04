Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Pause-Step {
    Set-Location "C:\Projects\MindLab_Starter_Project"
    Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
}

while ($true) {

    $existing = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*MindLab_Starter_Project*"
    }

    $conn = Get-NetTCPConnection -LocalPort 8085 -ErrorAction SilentlyContinue

    if (-not $conn -and -not $existing) {
        Write-Host "BACKEND DOWN → STARTING"
        Start-Process powershell -ArgumentList '-NoExit','-Command','cd C:\Projects\MindLab_Starter_Project\backend; node src/server.cjs'
    }

    Start-Sleep -Seconds 5
}
