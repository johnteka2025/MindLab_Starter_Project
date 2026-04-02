while ($true) {
    $port = Get-NetTCPConnection -LocalPort 8090 -ErrorAction SilentlyContinue

    if (-not $port) {
        Write-Host "[RECOVERY] Restarting frontend..."

        Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

        Start-Process powershell -ArgumentList "-NoExit","-Command","cd C:\Projects\MindLab_Starter_Project\frontend; npm run dev"

        Start-Sleep -Seconds 5
    }

    Start-Sleep -Seconds 10
}
