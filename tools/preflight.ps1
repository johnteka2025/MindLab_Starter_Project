[CmdletBinding()]
param(
  [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing required path: $p" }
}

Write-Host "== Preflight =="

Assert-Path (Join-Path $Root "backend\package.json")
Assert-Path (Join-Path $Root "tools\run_contract_clean.ps1")

# Ensure deps exist (jest.cmd must exist). If not, install in backend only.
$jestCmd = Join-Path $Root "backend\node_modules\.bin\jest.cmd"
if (-not (Test-Path $jestCmd)) {
  Write-Host "jest.cmd missing -> installing backend deps..."
  Push-Location (Join-Path $Root "backend")
  try {
    npm.cmd install
    if ($LASTEXITCODE -ne 0) { throw "npm install failed (exit $LASTEXITCODE)" }
  }
  finally { Pop-Location }
}

Assert-Path $jestCmd
Assert-Path (Join-Path $Root "backend\tests")

Write-Host "OK: preflight passed" -ForegroundColor Green
