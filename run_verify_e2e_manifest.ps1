# run_verify_e2e_manifest.ps1
# Verify that required E2E specs and npm scripts exist based on docs\e2e_manifest.json

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot     = "C:\Projects\MindLab_Starter_Project"
$manifestPath    = Join-Path $projectRoot "docs\e2e_manifest.json"
$frontendDir     = Join-Path $projectRoot "frontend"
$packageJsonPath = Join-Path $frontendDir "package.json"

Write-Host "== Verifying E2E manifest (spec files + npm scripts) =="

if (-not (Test-Path $manifestPath)) {
    Write-Host "ERROR: E2E manifest not found at: $manifestPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $packageJsonPath)) {
    Write-Host "ERROR: package.json not found at: $packageJsonPath" -ForegroundColor Red
    exit 1
}

# Load manifest JSON
try {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: e2e_manifest.json is not valid JSON." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Load package.json JSON
try {
    $pkg = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: package.json is not valid JSON." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$requiredSpecs  = $manifest.requiredSpecs
$optionalSpecs  = $manifest.optionalSpecs
$requiredScripts = $manifest.requiredScripts
$optionalScripts = $manifest.optionalScripts

if (-not $requiredSpecs)  { $requiredSpecs  = @() }
if (-not $optionalSpecs)  { $optionalSpecs  = @() }
if (-not $requiredScripts){ $requiredScripts = @() }
if (-not $optionalScripts){ $optionalScripts = @() }

$allOk    = $true
$warnings = 0

# --- Check required spec files ---
Write-Host "`n[CHECK] Required spec files" -ForegroundColor Cyan

foreach ($relPath in $requiredSpecs) {
    $fullPath = Join-Path $projectRoot $relPath
    if (-not (Test-Path $fullPath)) {
        Write-Host "ERROR: Required spec file missing: $fullPath" -ForegroundColor Red
        $allOk = $false
    } else {
        Write-Host "OK: $fullPath" -ForegroundColor Green
    }
}

# --- Check optional spec files ---
Write-Host "`n[CHECK] Optional spec files" -ForegroundColor Cyan

foreach ($relPath in $optionalSpecs) {
    $fullPath = Join-Path $projectRoot $relPath
    if (-not (Test-Path $fullPath)) {
        Write-Host "WARN: Optional spec file missing: $fullPath" -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host "OK: $fullPath" -ForegroundColor Green
    }
}

# --- Check required npm scripts ---
Write-Host "`n[CHECK] Required npm scripts in package.json" -ForegroundColor Cyan

$scripts = $pkg.scripts

foreach ($name in $requiredScripts) {
    $hasScript = $scripts.PSObject.Properties.Match($name).Count -gt 0
    if (-not $hasScript) {
        Write-Host "ERROR: Required npm script '$name' is missing from package.json." -ForegroundColor Red
        $allOk = $false
    } else {
        Write-Host ("OK: npm script '{0}' -> {1}" -f $name, $scripts.$name) -ForegroundColor Green
    }
}

# --- Check optional npm scripts ---
Write-Host "`n[CHECK] Optional npm scripts in package.json" -ForegroundColor Cyan

foreach ($name in $optionalScripts) {
    $hasScript = $scripts.PSObject.Properties.Match($name).Count -gt 0
    if (-not $hasScript) {
        Write-Host "WARN: Optional npm script '$name' is missing from package.json." -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host ("OK: npm script '{0}' -> {1}" -f $name, $scripts.$name) -ForegroundColor Green
    }
}

Write-Host ""

if (-not $allOk) {
    Write-Host "E2E manifest verification FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "E2E manifest verification PASSED." -ForegroundColor Green
if ($warnings -gt 0) {
    Write-Host "Note: $warnings warning(s) about optional specs/scripts were reported." -ForegroundColor Yellow
}
exit 0
