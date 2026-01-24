param()

$ErrorActionPreference = "Stop"

# Resolve repo root and tool paths deterministically
$RepoRoot   = Resolve-Path (Join-Path $PSScriptRoot "..")
$ToolsDir   = Resolve-Path $PSScriptRoot

$Preflight  = Join-Path $ToolsDir "preflight.ps1"
$GuardNoPm  = Join-Path $ToolsDir "guard_no_pm.ps1"
$Contracts  = Join-Path $ToolsDir "run_contract_clean.ps1"

function Invoke-PSFile([string]$Path) {
  if (-not (Test-Path $Path)) { throw "Missing required script: $Path" }
  powershell -NoProfile -ExecutionPolicy Bypass -File $Path
  if ($LASTEXITCODE -ne 0) { throw "Script failed (exit $LASTEXITCODE): $Path" }
}

Write-Host ""
Write-Host "== Guard (no pm) =="

Invoke-PSFile $GuardNoPm

Write-Host ""
Write-Host "== Preflight =="

Invoke-PSFile $Preflight

Write-Host ""
Write-Host "== Unit tests =="

Push-Location (Join-Path $RepoRoot "backend")
try {
  npm.cmd test
  if ($LASTEXITCODE -ne 0) { throw "Unit tests failed (exit $LASTEXITCODE)" }
} finally { Pop-Location }

Write-Host ""
Write-Host "== Contract tests =="

Invoke-PSFile $Contracts

Write-Host ""
Write-Host "ALL TESTS GREEN" -ForegroundColor Green
