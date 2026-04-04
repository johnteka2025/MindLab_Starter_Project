Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Kill-Port($port) {
    $conns = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($conns) {
        $procIds = $conns | Select-Object -ExpandProperty OwningProcess -Unique
        foreach ($procId in $procIds) {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        }
    }
}

Kill-Port 8085
Kill-Port 8090

Start-Sleep -Seconds 3
