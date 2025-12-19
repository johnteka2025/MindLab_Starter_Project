param()

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " BACKUP: Full-check scripts + e2e specs" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# --- Paths and folders ---
$projectRoot = "C:\Projects\MindLab_Starter_Project\frontend"
$backupRoot  = Join-Path $projectRoot "backups"

# Timestamped backup folder: backups\fullcheck_YYYYMMDD_HHmm
$stamp      = Get-Date -Format "yyyyMMdd_HHmm"
$backupDir  = Join-Path $backupRoot ("fullcheck_" + $stamp)
$scriptsDir = Join-Path $backupDir "scripts"
$testsDir   = Join-Path $backupDir "tests_e2e"

Write-Host "[INFO] Backup root : $backupRoot"
Write-Host "[INFO] Scripts dir : $scriptsDir"
Write-Host "[INFO] Specs   dir : $testsDir"

# Ensure folders exist
New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
New-Item -ItemType Directory -Path $testsDir -Force  | Out-Null

# --- Helper scripts to copy (optional, no failure if missing) ---
$scriptsToCopy = @(
    "run_all.ps1",
    "sanity_local.ps1",
    "run_frontend_ui_smoke.ps1",
    "run_ui_suite.ps1",
    "run_game_flow_ui.ps1"
)

Write-Host ""
Write-Host "STEP] Copying helper scripts (optional)..." -ForegroundColor Yellow

foreach ($name in $scriptsToCopy) {
    $src = Join-Path $projectRoot $name
    if (Test-Path $src) {
        $dst = Join-Path $scriptsDir $name
        Copy-Item $src $dst -Force
        Write-Host "  Copied script: $name" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARN] Script not found, skipping: $src" -ForegroundColor DarkYellow
    }
}

# --- e2e specs to copy (these should all exist) ---
$specsToCopy = @(
    "tests\e2e\daily-challenge.spec.ts",
    "tests\e2e\daily-challenge-prod.spec.ts",
    "tests\e2e\health-and-puzzles.spec.ts",
    "tests\e2e\mindlab-basic.spec.ts",
    "tests\e2e\mindlab-daily-result.spec.ts",
    "tests\e2e\mindlab-daily-solve.spec.ts",
    "tests\e2e\mindlab-daily-ui.spec.ts",
    "tests\e2e\mindlab-daily-ui-optional.spec.ts",
    "tests\e2e\mindlab-health-ui.spec.ts",
    "tests\e2e\mindlab-prod.spec.ts",
    "tests\e2e\mindlab-progress-ui.spec.ts",
    "tests\e2e\progress-api.spec.ts",
    "tests\e2e\progress-api-prod.spec.ts",
    "tests\e2e\progress-ui.spec.ts",
    "tests\e2e\puzzles-navigation.spec.ts",
    "tests\e2e\mindlab-game-flow.spec.ts"   # NEW game-flow spec
)

Write-Host ""
Write-Host "STEP] Copying e2e spec files..." -ForegroundColor Yellow

$missingSpecs = @()

foreach ($rel in $specsToCopy) {
    $src = Join-Path $projectRoot $rel
    if (Test-Path $src) {
        # Preserve folder structure under tests_e2e
        $fileName = Split-Path $rel -Leaf
        $dst = Join-Path $testsDir $fileName
        Copy-Item $src $dst -Force
        Write-Host "  Copied spec: $fileName" -ForegroundColor Green
    }
    else {
        $missingSpecs += $rel
        Write-Host "  [ERROR] Spec file not found: $src" -ForegroundColor Red
    }
}

if ($missingSpecs.Count -gt 0) {
    Write-Host ""
    Write-Host "[RESULT] Backup completed WITH MISSING SPEC FILES." -ForegroundColor Red
    Write-Host "The following specs were not copied:" -ForegroundColor Red
    $missingSpecs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Backup folder (partial): $backupDir" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[RESULT] Backup completed successfully." -ForegroundColor Green
Write-Host "[RESULT] Backup folder: $backupDir" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan

exit 0
