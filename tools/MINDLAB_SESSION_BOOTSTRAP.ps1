Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root        = "C:\Projects\MindLab_Starter_Project"
$Backend     = "C:\Projects\MindLab_Starter_Project\backend"
$Frontend    = "C:\Projects\MindLab_Starter_Project\frontend"
$Src         = "C:\Projects\MindLab_Starter_Project\frontend\src"
$AppDir      = "C:\Projects\MindLab_Starter_Project\frontend\src\app"
$DataDir     = "C:\Projects\MindLab_Starter_Project\frontend\src\data\kids"
$UiDir       = "C:\Projects\MindLab_Starter_Project\frontend\src\ui"
$EngineDir   = "C:\Projects\MindLab_Starter_Project\frontend\src\engine"
$GameDir     = "C:\Projects\MindLab_Starter_Project\backend\src\game"
$DataStore   = "C:\Projects\MindLab_Starter_Project\backend\src\data"
$DocsDeploy  = "C:\Projects\MindLab_Starter_Project\docs\deployment"
$DocsQa      = "C:\Projects\MindLab_Starter_Project\docs\qa"
$Tools       = "C:\Projects\MindLab_Starter_Project\tools"
$Backups     = "C:\Projects\MindLab_Starter_Project\tools\backups"
$TestsDir    = "C:\Projects\MindLab_Starter_Project\tests"

Set-Location $Root
New-Item -ItemType Directory -Force $Backups | Out-Null
New-Item -ItemType Directory -Force $DocsDeploy | Out-Null
New-Item -ItemType Directory -Force $DocsQa | Out-Null
New-Item -ItemType Directory -Force $TestsDir | Out-Null

function Pause-Step {
    Set-Location $Root
    Read-Host "Press ENTER to continue (PowerShell stays open)" | Out-Null
    Set-Location $Root
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Force $dir | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Backup-File {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (Test-Path $Path) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $name  = Split-Path $Path -Leaf
        Copy-Item $Path (Join-Path $Backups "$stamp.$name.bak") -Force
    }
}

function Invoke-Preflight {
    Set-Location $Root
    git restore --source=HEAD --staged --worktree "tools\backend.pid" 2>$null
    git status --short
    powershell -NoProfile -ExecutionPolicy Bypass `
        -File "$Tools\CHECK_REPO_STATE_BEFORE_COMMIT.ps1"
    $status = @(git status --porcelain)
    if ($status.Count -gt 0) {
        Write-Host "STOP: repository is dirty before this task group." -ForegroundColor Red
        git status --short | Out-Host
        throw "Unexpected dirty repository"
    }
}

function Invoke-Sanity {
    Set-Location $Root
    powershell -NoProfile -ExecutionPolicy Bypass `
        -File "$Tools\RECOVER_BACKEND_AND_RERUN_SANITY.ps1"
    git status --short
}

function Test-JsFiles {
    param([Parameter(Mandatory = $true)][string[]]$Files)
    foreach ($f in $Files) {
        if (!(Test-Path $f)) { throw "Missing file: $f" }
        node --check $f
    }
}

function Add-AndCommitExact {
    param(
        [Parameter(Mandatory = $true)][string[]]$Files,
        [Parameter(Mandatory = $true)][string]$Message
    )
    Set-Location $Root
    foreach ($f in $Files) {
        if (!(Test-Path $f)) { throw "Cannot stage missing file: $f" }
        git add -- $f
    }
    $staged = @(git diff --cached --name-only)
    if ($staged.Count -eq 0) { throw "Nothing staged. Stop here." }
    $staged | Out-Host
    git commit -m $Message
}

function Add-AndCommitForcePaths {
    param(
        [Parameter(Mandatory = $true)][string[]]$Files,
        [Parameter(Mandatory = $true)][string]$Message
    )
    Set-Location $Root
    foreach ($f in $Files) {
        if (!(Test-Path $f)) { throw "Cannot stage missing file: $f" }
        git add -f -- $f
    }
    $staged = @(git diff --cached --name-only)
    if ($staged.Count -eq 0) { throw "Nothing staged. Stop here." }
    $staged | Out-Host
    git commit -m $Message
}

function Start-CleanServices {
    Set-Location $Root
    Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2

    Start-Process powershell -ArgumentList `
        "-NoExit", `
        "-Command", `
        "Set-Location '$Backend'; node src/server.cjs"

    Start-Sleep -Seconds 5

    Start-Process powershell -ArgumentList `
        "-NoExit", `
        "-Command", `
        "Set-Location '$Frontend'; cmd /c npm run dev"

    Start-Sleep -Seconds 8
}

function Assert-SingleEntrypoint {
    $resolver = "C:\Projects\MindLab_Starter_Project\tools\RESOLVE_FRONTEND_ENTRYPOINT.ps1"
    if (!(Test-Path $resolver)) { throw "Missing file: $resolver" }
    $selected = & powershell -NoProfile -ExecutionPolicy Bypass -File $resolver
    if (-not $selected) { throw "Entrypoint resolution failed" }
    return (($selected | Select-Object -Last 1).ToString().Trim())
}

Set-Location $Root