param(
    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "C:\Projects\MindLab_Starter_Project\tools\COMMON_SAFE_RUNNER.ps1"

try {
    Set-Location "C:\Projects\MindLab_Starter_Project"

    $staged = git diff --cached --name-only
    if ($staged) {
        $staged | Out-Host
        Complete-Step -Code 0 -Message "OK: staged files exist"
        return
    }

    $status = git status --porcelain
    if (-not $status) {
        Complete-Step -Code 2 -Message "STOP: nothing to commit; repo already clean"
        return
    }

    git add -A
    if ($LASTEXITCODE -ne 0) { throw "STOP: git add -A failed" }

    $stagedAfter = git diff --cached --name-only
    if (-not $stagedAfter) {
        throw "STOP: files exist but nothing staged after git add -A"
    }

    $stagedAfter | Out-Host
    Complete-Step -Code 0 -Message "OK: staged all pending changes"
}
catch {
    Complete-Step -Code 1 -Message $_
}
finally {
    if (-not $NoPause) { Wait-ForUser }
}
