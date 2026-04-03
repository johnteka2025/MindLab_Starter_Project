Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location 'C:\Projects\MindLab_Starter_Project'

$viteConn = Get-NetTCPConnection -LocalPort 8090 -ErrorAction SilentlyContinue

if ($viteConn) {
    $pids = @()
    foreach ($conn in $viteConn) {
        if ($conn.OwningProcess -and ($pids -notcontains $conn.OwningProcess)) {
            $pids += $conn.OwningProcess
        }
    }

    foreach ($pid in $pids) {
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}

Start-Sleep -Seconds 2

Start-Process cmd.exe -ArgumentList '/k','cd /d C:\Projects\MindLab_Starter_Project\frontend && npm run dev'
