# run_next_steps_suite.ps1
# Orchestrates MindLab next-step checks (UI + backend + puzzles)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"

function Invoke-Step {
    param(
        [string] $Name,
        [string] $ScriptPath
    )

    Write-Host "`n== $Name ==" -ForegroundColor Cyan

    if (-not (Test-Path $ScriptPath)) {
        Write-Host "SKIP: Script not found: $ScriptPath" -ForegroundColor Yellow
        return $true
    }

    & $ScriptPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "STEP FAILED: $Name (exit code $LASTEXITCODE)" -ForegroundColor Red
        return $false
    }

    Write-Host "STEP PASSED: $Name" -ForegroundColor Green
    return $true
}

$steps = @(
    @{ Name = "Verify Environment";              Path = Join-Path $projectRoot "verify_mindlab_environment.ps1" },
    @{ Name = "Verify E2E Manifest";             Path = Join-Path $projectRoot "run_verify_e2e_manifest.ps1" },
    @{ Name = "Clean Duplicate Specs";           Path = Join-Path $projectRoot "clean_mindlab_specs.ps1" },
    @{ Name = "Expand Daily UI Coverage";        Path = Join-Path $projectRoot "expand_daily_ui_coverage.ps1" },
    @{ Name = "Expand Optional Daily UI Coverage"; Path = Join-Path $projectRoot "expand_daily_ui_optional_coverage.ps1" },
    @{ Name = "Expand Progress UI Coverage";     Path = Join-Path $projectRoot "expand_progress_ui_coverage.ps1" },
    @{ Name = "Validate Puzzles JSON";           Path = Join-Path $projectRoot "validate_puzzles_json.ps1" },
    @{ Name = "Backend /puzzles Contract Test";  Path = Join-Path $projectRoot "run_backend_puzzles_contract.ps1" },
    @{ Name = "Backend API Error Tests";         Path = Join-Path $projectRoot "run_backend_api_error_tests.ps1" },
    @{ Name = "Backend API Smoke Test";          Path = Join-Path $projectRoot "run_backend_api_smoke.ps1" }
)

$allOk = $true

foreach ($s in $steps) {
    $ok = Invoke-Step -Name $s.Name -ScriptPath $s.Path
    if (-not $ok) {
        $allOk = $false
        break
    }
}

if (-not $allOk) {
    Write-Host "`nNext-steps suite FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "`nNext-steps suite PASSED. Daily UI, optional daily UI, Progress UI, backend, and puzzles are all healthy." -ForegroundColor Green
exit 0
