param(
    [switch]$TraceOn,
    # Relative path from project root to your main Express server file.
    # If your main file is different (e.g. backend\src\index.ts), you can run:
    #   .\run_phase12_wire_router.ps1 -ServerFile "backend\src\index.ts"
    [string]$ServerFile = "backend\src\server.ts"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 12 - Wire Daily Challenge router ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
Write-Host "Server file (relative): $ServerFile"
if ($TraceOn) { Write-Host "Trace mode: ON" -ForegroundColor Yellow }

$serverPath = Join-Path $root $ServerFile

if (-not (Test-Path $serverPath)) {
    Write-Host ("ERROR: Server file not found at: {0}" -f $serverPath) -ForegroundColor Red
    Write-Host ""
    Write-Host "Hint: Check which file creates your Express app (const app = express())." -ForegroundColor Yellow
    Write-Host "Then re-run with the correct relative path, e.g.:" -ForegroundColor Yellow
    Write-Host "  .\run_phase12_wire_router.ps1 -ServerFile 'backend\src\index.ts'" -ForegroundColor Yellow
    Write-Host "[RESULT] Phase 12 wiring: FAILED (server file missing)" -ForegroundColor Red
    exit 1
}

Write-Host ("Using server file: {0}" -f $serverPath) -ForegroundColor Green

# Read whole file
$content = Get-Content $serverPath -Raw

# If already wired, exit early
if ($content -match 'createDailyChallengeRouter' -and $content -match 'app\.use\(\s*createDailyChallengeRouter\(\)\s*\)') {
    Write-Host "Daily Challenge router already wired. No changes made." -ForegroundColor Yellow
    Write-Host "[RESULT] Phase 12 wiring: PASSED (already up to date)" -ForegroundColor Green
    exit 0
}

# -----------------------
# 1) Ensure import line exists
# -----------------------
$importLine = 'import { createDailyChallengeRouter } from "./daily-challenge/dailyChallengeRoutes";'

if ($content -notmatch [regex]::Escape($importLine)) {
    Write-Host "Adding import for createDailyChallengeRouter..." -ForegroundColor Cyan

    $lines = $content -split "(`r`n|`n|`r)"
    $importIndices = @()

    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*import\s+') {
            $importIndices += $i
        }
    }

    if ($importIndices.Count -eq 0) {
        # No import lines; prepend at top
        $newLines = @($importLine) + "" + $lines
    } else {
        $lastImportIndex = $importIndices[-1]
        $newLines = @()
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $newLines += $lines[$i]
            if ($i -eq $lastImportIndex) {
                $newLines += $importLine
            }
        }
    }

    $content = ($newLines -join "`r`n")
} else {
    Write-Host "Import for createDailyChallengeRouter already present." -ForegroundColor Yellow
}

# -----------------------
# 2) Ensure app.use(createDailyChallengeRouter()) exists
# -----------------------
$appUseLine = 'app.use(createDailyChallengeRouter());'

if ($content -notmatch [regex]::Escape($appUseLine)) {
    Write-Host "Adding app.use(createDailyChallengeRouter())..." -ForegroundColor Cyan

    $lines = $content -split "(`r`n|`n|`r)"

    # Try to insert after app.use(express.json());
    $insertIndex = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match 'app\.use\(\s*express\.json\(\)\s*\)') {
            $insertIndex = $i
        }
    }

    if ($insertIndex -ge 0) {
        $newLines = @()
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $newLines += $lines[$i]
            if ($i -eq $insertIndex) {
                $newLines += $appUseLine
            }
        }
    } else {
        # Fallback: insert after const app = express();
        $insertIndex = -1
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match 'const\s+app\s*=\s*express\(\)\s*;') {
                $insertIndex = $i
                break
            }
        }

        if ($insertIndex -ge 0) {
            $newLines = @()
            for ($i = 0; $i -lt $lines.Length; $i++) {
                $newLines += $lines[$i]
                if ($i -eq $insertIndex) {
                    $newLines += $appUseLine
                }
            }
        } else {
            Write-Host "ERROR: Could not find 'app.use(express.json())' or 'const app = express();' in server file." -ForegroundColor Red
            Write-Host "Please review the file manually and decide where to mount the router, then re-run if needed." -ForegroundColor Red
            Write-Host "[RESULT] Phase 12 wiring: FAILED (no suitable insertion point)" -ForegroundColor Red
            exit 1
        }
    }

    $content = ($newLines -join "`r`n")
} else {
    Write-Host "app.use(createDailyChallengeRouter()) already present." -ForegroundColor Yellow
}

# -----------------------
# 3) Write updated file
# -----------------------
try {
    Set-Content -Path $serverPath -Value $content -Encoding UTF8
    Write-Host ("Updated server file: {0}" -f $serverPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing server file: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 wiring: FAILED (write error)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 12 wiring: PASSED (router wired successfully)" -ForegroundColor Green
exit 0
