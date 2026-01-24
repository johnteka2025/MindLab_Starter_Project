[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$preflight = Join-Path $root "tools\preflight.ps1"
$runner    = Join-Path $root "tools\run_contract_clean.ps1"

if (-not (Test-Path $preflight)) { throw "Missing: $preflight" }
if (-not (Test-Path $runner)) { throw "Missing: $runner" }

# 0) Guard against forbidden tokens
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path \ "tools\guard_no_pm.ps1")
# 1) Preflight
powershell -NoProfile -ExecutionPolicy Bypass -File $preflight

# 2) Unit tests (run inside backend; NEVER use --prefix)
Write-Host ""
Write-Host "== Unit tests =="

Push-Location (Join-Path $root "backend")
try {
  npm.cmd test
  if ($LASTEXITCODE -ne 0) { throw "Unit tests failed (exit $LASTEXITCODE)" }
}
finally { Pop-Location }

# 3) Contract tests (deterministic runner)
Write-Host ""
Write-Host "== Contract tests =="

powershell -NoProfile -ExecutionPolicy Bypass -File $runner

Write-Host ""
Write-Host "ALL TESTS GREEN" -ForegroundColor Green

