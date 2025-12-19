$ErrorActionPreference = 'Stop'

Write-Host "=== MindLab UI Suite ===" -ForegroundColor Cyan

# Ensure we are in the project root (same folder as this script)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

function Run-Step {
    param(
        [string]$Name,
        [string]$Script,
        [bool]$Optional = $false
    )

    # If the script file itself is missing
    if (-not (Test-Path $Script)) {
        if ($Optional) {
            Write-Host "[OPTIONAL] $Name : SKIPPED (file missing)" -ForegroundColor Yellow
            $exit = 0      # optional missing = treat as pass
        }
        else {
            Write-Host "[REQUIRED] $Name : FAILED (file missing)" -ForegroundColor Red
            $exit = 99     # special code for missing required script
        }

        return @{
            Name     = $Name
            Optional = $Optional
            ExitCode = $exit
        }
    }

    # Run the step script
    & $Script
    $code = $LASTEXITCODE

    # Build a tag WITHOUT using ternary operators
    $tag = ''
    if ($Optional) {
        $tag = "[OPTIONAL]"
    }
    else {
        $tag = "[REQUIRED]"
    }

    if ($code -eq 0) {
        Write-Host "$tag $Name : PASSED (exit code 0)" -ForegroundColor Green
    }
    else {
        Write-Host "$tag $Name : FAILED (exit code $code)" -ForegroundColor Red
    }

    return @{
        Name     = $Name
        Optional = $Optional
        ExitCode = $code
    }
}

# ----------------------------
# 1) REQUIRED: Daily UI test
# ----------------------------
$dailyScript = Join-Path $projectRoot 'run_daily_ui_test.ps1'

$daily = Run-Step `
    -Name   'Daily UI Playwright test' `
    -Script $dailyScript `
    -Optional:$false

# ----------------------------
# 2) OPTIONAL: Daily UI optional test
#    Only run if the optional spec file exists
# ----------------------------
$optionalSpec   = Join-Path $projectRoot 'frontend\tests\e2e\mindlab-daily-ui-optional.spec.ts'
$optionalScript = Join-Path $projectRoot 'run_daily_ui_optional_test.ps1'

$opt = $null

if (Test-Path $optionalSpec) {
    # Spec exists: run optional script (if present)
    $opt = Run-Step `
        -Name     'Optional Daily UI test' `
        -Script   $optionalScript `
        -Optional:$true
}
else {
    # Spec missing: log and treat as success
    Write-Host "[OPTIONAL] Optional Daily UI test : SKIPPED (spec missing)" -ForegroundColor Yellow
    $opt = @{
        Name     = 'Optional Daily UI test'
        Optional = $true
        ExitCode = 0
    }
}

# ----------------------------
# 3) SUMMARY & FINAL EXIT CODE
# ----------------------------
Write-Host ""
Write-Host "==== UI SUITE SUMMARY ====" -ForegroundColor Cyan

# Required result
if ($daily.ExitCode -eq 0) {
    Write-Host "[REQUIRED] Daily UI test PASSED" -ForegroundColor Green
}
else {
    Write-Host "[REQUIRED] Daily UI test FAILED (exit code $($daily.ExitCode))" -ForegroundColor Red
}

# Optional result
if ($opt.ExitCode -eq 0) {
    Write-Host "[OPTIONAL] Optional Daily UI checks PASSED or were skipped." -ForegroundColor Green
}
else {
    Write-Host "[OPTIONAL] Optional Daily UI checks FAILED (exit code $($opt.ExitCode))." -ForegroundColor Yellow
}

# Final decision: only required tests control process exit code
if ($daily.ExitCode -eq 0) {
    exit 0
}
else {
    exit 1
}
