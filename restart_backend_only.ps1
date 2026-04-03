Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location 'C:\Projects\MindLab_Starter_Project'

$apiConn = Get-NetTCPConnection -LocalPort 8085 -ErrorAction SilentlyContinue

if ($apiConn) {
    $pids = @()
    foreach ($conn in $apiConn) {
        if ($conn.OwningProcess -and ($pids -notcontains $conn.OwningProcess)) {
            $pids += $conn.OwningProcess
        }
    }

    foreach ($pid in $pids) {
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}

Start-Sleep -Seconds 2

Start-Process powershell -ArgumentList '-NoExit','-Command','cd C:\Projects\MindLab_Starter_Project\backend; node src/server.cjs'
