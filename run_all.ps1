param(
    [switch]$SkipDocker
)

Write-Host '=== MindLab FULL TEST RUN (local + docker) ===' -ForegroundColor Cyan

# Step 1 — Local full smoke
Write-Host ''
Write-Host '[1/2] Running full_smoke.ps1 (local)...' -ForegroundColor Yellow

$fullSmoke = Join-Path $PSScriptRoot 'full_smoke.ps1'
if (-not (Test-Path $fullSmoke)) {
    Write-Host 'ERROR: full_smoke.ps1 not found in project root.' -ForegroundColor Red
    exit 1
}

& $fullSmoke
$fullExit = $LASTEXITCODE

if ($fullExit -ne 0) {
    Write-Host ''
    Write-Host 'FULL SMOKE FAILED. Skipping docker smoke.' -ForegroundColor Red
    exit $fullExit
}

Write-Host ''
Write-Host 'Local FULL SMOKE PASSED ✅' -ForegroundColor Green

if ($SkipDocker) {
    Write-Host ''
    Write-Host 'SkipDocker flag set — Docker smoke will not run.' -ForegroundColor Yellow
    Write-Host '=== MASTER TEST RUN COMPLETE (LOCAL ONLY) ===' -ForegroundColor Cyan
    exit 0
}

# Step 2 — Docker smoke
Write-Host ''
Write-Host '[2/2] Running docker_smoke.ps1...' -ForegroundColor Yellow

$dockerSmoke = Join-Path $PSScriptRoot 'docker_smoke.ps1'
if (-not (Test-Path $dockerSmoke)) {
    Write-Host 'ERROR: docker_smoke.ps1 not found in project root.' -ForegroundColor Red
    exit 1
}

& $dockerSmoke
$dockerExit = $LASTEXITCODE

if ($dockerExit -ne 0) {
    Write-Host ''
    Write-Host 'DOCKER SMOKE FAILED.' -ForegroundColor Red
    exit $dockerExit
}

Write-Host ''
Write-Host 'Docker SMOKE PASSED ✅' -ForegroundColor Green

Write-Host ''
Write-Host '=== ALL TESTS PASSED (LOCAL + DOCKER) 🎉 ===' -ForegroundColor Cyan
exit 0
