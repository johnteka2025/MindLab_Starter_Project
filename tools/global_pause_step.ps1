function Pause-Step {
    try {
        Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
    } catch {
        Write-Host "Pause-Step fallback executed"
    }
}
