[CmdletBinding()]
param(
  [string]$TestPath = "",
  [int]$Port = 3000,
  [switch]$NoServer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$failed = 0

function Finish {
  param(
    [Parameter(Mandatory=$true)][int]$Code,
    [Parameter(Mandatory=$true)][string]$Message
  )
  if ($Code -ne 0) { Write-Host $Message -ForegroundColor Red } else { Write-Host $Message -ForegroundColor Green }
  $global:LASTEXITCODE = $Code
  return
}

$repoRoot = (Resolve-Path ".").Path
$backend  = Join-Path $repoRoot "backend"
if (-not (Test-Path $backend)) { Finish 1 "STOP: backend folder missing."; return }

$npmExe = (Get-Command npm.cmd -ErrorAction Stop).Source
$jestCmd = Join-Path $backend "node_modules\.bin\jest.cmd"
if (-not (Test-Path $jestCmd)) { Finish 1 "STOP: jest.cmd not found. Run: npm ci in backend."; return }

$base = "http://127.0.0.1:$Port"
$env:CONTRACT_BASE = $base

# Ensure server is up unless NoServer is set
$serverStarted = $false
if (-not $NoServer) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri "$base/health" -TimeoutSec 2
    if ($r.StatusCode -ne 200) { throw "not-200" }
  } catch {
    & (Join-Path $repoRoot "tools\start_backend_for_contracts.ps1") -Port $Port
    $serverStarted = $true
  }
}

Write-Host "Using npm  => $npmExe"  -ForegroundColor Cyan
Write-Host "Using jest => $jestCmd" -ForegroundColor Cyan
Write-Host "Base URL   => $base" -ForegroundColor Cyan

# Discover tests
$tests = @()
if ($TestPath) {
  $tests = @((Resolve-Path $TestPath).Path)
} else {
  $tests = Get-ChildItem (Join-Path $backend "tests\contract") -Filter "*.contract.test.js" -Recurse |
           Select-Object -ExpandProperty FullName
}

if ($tests.Count -eq 0) {
  if ($serverStarted) { & (Join-Path $repoRoot "tools\stop_backend_for_contracts.ps1") }
  Finish 1 "STOP: No contract tests found under backend\tests\contract."
  return
}

foreach ($t in $tests) {
  Write-Host "Running contract test => $t" -ForegroundColor Cyan
  Push-Location $backend
  & $jestCmd --runInBand --runTestsByPath $t
  $exit = $LASTEXITCODE
  Pop-Location

  if ($exit -ne 0) {
    $failed++
    Write-Host ("FAIL: jest exited with code {0}" -f $exit) -ForegroundColor Red
  }
}

if ($serverStarted) { & (Join-Path $repoRoot "tools\stop_backend_for_contracts.ps1") }

if ($failed -gt 0) { Finish 1 ("STOP: Contract run finished with failures: {0}" -f $failed); return }

Write-Host ""
Write-Host "== All contract tests green ==" -ForegroundColor Green
Finish 0 "OK: Contract tests green."
