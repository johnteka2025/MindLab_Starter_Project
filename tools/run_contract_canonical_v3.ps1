[CmdletBinding()]
param(
  [string]$TestPath = ""
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

# Resolve npm and jest directly (do NOT use `npm test` because it ignores tests/contract)
$npmExe = (Get-Command npm.cmd -ErrorAction Stop).Source

$jestCmd = Join-Path $backend "node_modules\.bin\jest.cmd"
if (-not (Test-Path $jestCmd)) {
  Finish 1 "STOP: jest.cmd not found. Run: npm ci (or npm i) in backend first."
  return
}

Write-Host "Using npm  => $npmExe"  -ForegroundColor Cyan
Write-Host "Using jest => $jestCmd" -ForegroundColor Cyan

# Discover contract tests
$tests = @()
if ($TestPath) {
  $tests = @((Resolve-Path $TestPath).Path)
} else {
  $tests = Get-ChildItem (Join-Path $backend "tests\contract") -Filter "*.contract.test.js" -Recurse |
           Select-Object -ExpandProperty FullName
}

if ($tests.Count -eq 0) { Finish 1 "STOP: No contract tests found under backend\tests\contract."; return }

foreach ($t in $tests) {
  Write-Host "Running contract test => $t" -ForegroundColor Cyan

  # Run Jest directly to bypass package.json test script ignore patterns
  Push-Location $backend
  & $jestCmd --runInBand --runTestsByPath $t
  $exit = $LASTEXITCODE
  Pop-Location

  if ($exit -ne 0) {
    $failed++
    Write-Host ("FAIL: jest exited with code {0}" -f $exit) -ForegroundColor Red
  }
}

if ($failed -gt 0) { Finish 1 ("STOP: Contract run finished with failures: {0}" -f $failed); return }

Write-Host ""
Write-Host "== All contract tests green ==" -ForegroundColor Green
Finish 0 "OK: Contract tests green."
