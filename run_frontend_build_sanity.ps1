Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  MindLab Frontend BUILD + DIST Sanity" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendDir  = Join-Path $projectRoot "frontend"

Write-Host "Project root : $projectRoot"
Write-Host "Frontend dir : $frontendDir"
Write-Host ""

# STEP 1 – Go to frontend and run npm run build
Write-Host "[STEP 1] Running npm run build in frontend..." -ForegroundColor Yellow
Set-Location $frontendDir
Write-Host "Current dir: $(Get-Location)"

npm run build
$exitCode = $LASTEXITCODE
Write-Host ""

if ($exitCode -ne 0) {
    Write-Host "[RESULT] Frontend build FAILED (exit code $exitCode)" -ForegroundColor Red
    Write-Host "Check the npm output above for TypeScript/React errors."
    # Go back to project root before exiting
    Set-Location $projectRoot
    Write-Host "Back at project root: $(Get-Location)"
    exit $exitCode
}

Write-Host "[STEP 1] npm run build completed with exit code 0." -ForegroundColor Green
Write-Host ""

# STEP 2 – List dist folder
Write-Host "[STEP 2] Listing .\\dist folder..." -ForegroundColor Yellow
if (-not (Test-Path ".\dist")) {
    Write-Host "ERROR: .\dist folder does NOT exist after build!" -ForegroundColor Red
} else {
    Get-ChildItem ".\dist"
}

Write-Host ""

# STEP 3 – List dist/assets folder
Write-Host "[STEP 3] Listing .\\dist\\assets folder..." -ForegroundColor Yellow
if (-not (Test-Path ".\dist\assets")) {
    Write-Host "WARNING: .\dist\assets folder does NOT exist. Something is wrong with the build output." -ForegroundColor Red
} else {
    Get-ChildItem ".\dist\assets"
}

Write-Host ""
Write-Host "[RESULT] Frontend build + dist sanity: COMPLETED." -ForegroundColor Green
Write-Host "If your frontend dev server (npm start) is already running on port 5177," -ForegroundColor Green
Write-Host "just reload http://localhost:5177/app and http://localhost:5177/app/daily in the browser." -ForegroundColor Green

# STEP 4 – Return to project root
Set-Location $projectRoot
Write-Host ""
Write-Host "Back at project root: $(Get-Location)" -ForegroundColor Cyan
