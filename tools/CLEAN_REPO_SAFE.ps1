Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $REPO = "C:\Projects\MindLab_Starter_Project"

    if (!(Test-Path $REPO)) {
        throw "STOP: repo missing"
    }

    Set-Location $REPO

    $status = git status --porcelain
    if (-not $status) {
        Write-Host "OK: repository already clean" -ForegroundColor Green
        return
    }

    $tracked = @()
    $untracked = @()

    foreach ($line in $status) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line.Length -lt 4) { continue }

        $code = $line.Substring(0,2)
        $path = $line.Substring(3).Trim()

        if ($code -eq "??") {
            $untracked += $path
        }
        else {
            $tracked += $path
        }
    }

    if ($tracked.Count -gt 0) {
        $tracked | Sort-Object -Unique | Out-Host
        throw "STOP: tracked changes exist; backup or commit required before continuing"
    }

    foreach ($item in ($untracked | Sort-Object -Unique)) {
        $full = Join-Path $REPO $item
        if (Test-Path -LiteralPath $full) {
            Remove-Item -LiteralPath $full -Recurse -Force
            Write-Host "REMOVED: $item" -ForegroundColor Yellow
        }
    }

    $finalStatus = git status --porcelain
    if ($finalStatus) {
        $finalStatus | Out-Host
        throw "STOP: repository still dirty after safe clean"
    }

    Write-Host "OK: CLEAN_REPO_SAFE completed" -ForegroundColor Green
}
catch {
    Write-Host $_ -ForegroundColor Red
}
finally {
    Read-Host "Press ENTER (PowerShell stays open)"
}
