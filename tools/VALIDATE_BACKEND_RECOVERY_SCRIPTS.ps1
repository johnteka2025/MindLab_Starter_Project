Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $Repo = "C:\Projects\MindLab_Starter_Project"
    Set-Location $Repo

    $files = @(
        "$Repo\tools\STOP_BACKEND_SAFE.ps1",
        "$Repo\tools\START_BACKEND_SAFE.ps1",
        "$Repo\tools\WAIT_FOR_BACKEND_HEALTH.ps1",
        "$Repo\tools\RECOVER_BACKEND_AND_RERUN_SANITY.ps1"
    )

    foreach ($file in $files) {
        if (!(Test-Path $file)) { throw "STOP: missing file $file" }

        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)

        if ($null -eq $ast) { throw "STOP: parse engine returned null for $file" }

        if ($errors.Count -gt 0) {
            $errors | ForEach-Object { $_.ToString() } | Out-Host
            throw "STOP: PowerShell parse failed for $file"
        }
    }

    Write-Host "OK: backend recovery scripts parse validation passed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
