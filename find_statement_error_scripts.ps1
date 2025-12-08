# find_statement_error_scripts.ps1
# Find any PowerShell scripts that still use InvocationInfo.Statement

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"

Write-Host "== Searching for scripts that use InvocationInfo.Statement =="

if (-not (Test-Path $projectRoot)) {
    Write-Host "ERROR: Project root not found: $projectRoot" -ForegroundColor Red
    exit 1
}

$matches = Get-ChildItem -Path $projectRoot -Recurse -Include *.ps1 -File |
    Select-String -Pattern "InvocationInfo\.Statement" -SimpleMatch -ErrorAction SilentlyContinue

if (-not $matches) {
    Write-Host "No scripts found using 'InvocationInfo.Statement'." -ForegroundColor Green
    exit 0
}

Write-Host "Found the following scripts using 'InvocationInfo.Statement':" -ForegroundColor Yellow
$matches | ForEach-Object {
    Write-Host (" - {0}" -f $_.Path)
}

Write-Host "`nOpen each path above in Notepad and fix the catch block." -ForegroundColor Yellow
exit 0
