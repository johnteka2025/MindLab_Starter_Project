Set-Location "C:\Projects\MindLab_Starter_Project"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$RepoRoot = "C:\Projects\MindLab_Starter_Project"
function Pause-Safe {
    Set-Location $RepoRoot
    Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
    Set-Location $RepoRoot
}
# Populate source and destination paths before running any copy commands.
Pause-Safe