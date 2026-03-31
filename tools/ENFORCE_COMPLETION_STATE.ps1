Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location "C:\Projects\MindLab_Starter_Project"

$lockFile = "C:\Projects\MindLab_Starter_Project\docs\EXECUTION_LOCK.md"

if (!(Test-Path $lockFile)) {
    Write-Host "ERROR: Execution lock missing"
    exit 1
}

$content = Get-Content $lockFile -Raw

if ($content -notmatch "COMPLETE") {
    Write-Host "ERROR: Project not locked"
    exit 1
}

Write-Host "OK: Execution lock verified"
