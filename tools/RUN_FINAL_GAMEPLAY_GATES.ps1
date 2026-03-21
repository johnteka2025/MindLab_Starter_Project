param([switch]$NoPause)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"
try {
    Complete-Step -Code 0 -Message "OK: final gameplay gates placeholder passed"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
