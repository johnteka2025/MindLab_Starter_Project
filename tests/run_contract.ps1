[CmdletBinding()]
param([string]$BaseUrl="http://localhost:8085")

# Map localhost for containers
$baseForDocker = if ($BaseUrl -match "localhost|127\.0\.0\.1") { $BaseUrl -replace "localhost","host.docker.internal" } else { $BaseUrl }

$runId = (Get-Date).ToString("yyyyMMdd_HHmmss")
$artdir = Join-Path $PSScriptRoot ("..\artifacts\dredd_{0}" -f $runId)
New-Item -ItemType Directory -Force -Path $artdir | Out-Null
$log = Join-Path $artdir "dredd.console.log"

$specPath = Join-Path $PSScriptRoot "openapi.json"
if (-not (Test-Path $specPath)) { throw "Missing spec: $specPath" }

try { docker version *>$null } catch { throw "Docker not available for Dredd." }

Write-Host "[INFO] Dredd spec: $specPath"
Write-Host "[INFO] Dredd base: $baseForDocker"

$cmd = "docker run --rm -v `"$PSScriptRoot`:/scripts`" apiaryio/dredd:latest --color always --no-timeouts /scripts/openapi.json $baseForDocker"
powershell -NoProfile -Command "$cmd" 2>&1 | Tee-Object -FilePath $log | Out-String | Out-Null
$exit = $LASTEXITCODE
if ($exit -ne 0) { throw "Dredd exit $exit (see $log)" }
Write-Host "[OK]   Dredd passed (see $log)" -ForegroundColor Green
