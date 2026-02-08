[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$TestPath = "",
  [int]$Port = 8085,
  [int]$TimeoutSec = 30
)

$ErrorActionPreference = "Stop"
$npmExe = (Get-Command npm.cmd -ErrorAction SilentlyContinue).Source; if (-not $npmExe) { $npmExe = (Get-Command npm -ErrorAction Stop).Source }


function Finish {
  param(
    [Parameter(Mandatory=$true)][int]$Code,
    [Parameter(Mandatory=$true)][string]$Message
  )
  if ($Code -ne 0) { Write-Host $Message -ForegroundColor Red } else { Write-Host $Message -ForegroundColor Green }
  $global:LASTEXITCODE = $Code
  return
}



function Stop-PortProcess {
  param([int]$P)
  try {
    $conns = Get-NetTCPConnection -LocalPort $P -State Listen -ErrorAction Stop
    $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($procId in $pids) {
      if ($procId -and $procId -gt 0) { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue }
    }
  } catch { }
}

function Wait-Health200 {
  param([int]$P, [int]$WaitSec)
  $deadline = (Get-Date).AddSeconds($WaitSec)
  while ((Get-Date) -lt $deadline) {
    try {
      $code = & curl.exe -s -o NUL -w "%{http_code}" "http://localhost:$P/health"
      if ($code -eq "200") { return $true }
    } catch { }
    Start-Sleep -Milliseconds 250
  }
  return $false
}

$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root "backend"
if (-not (Test-Path $backend)) { throw "Missing backend folder: $backend" }

$contractDir = Join-Path $backend "tests\contract"
if (-not (Test-Path $contractDir)) { throw "Missing contract tests folder: $contractDir" }

# Resolve tests list
$tests = @()

if ([string]::IsNullOrWhiteSpace($TestPath)) {
  $tests = Get-ChildItem -Path $contractDir -Filter "*.test.js" -File | ForEach-Object { $_.FullName }
  if ($tests.Count -eq 0) { throw "No contract tests found under backend\tests\contract" }
} else {
  $candidate = Join-Path $backend $TestPath
  if (-not (Test-Path $candidate)) { throw "TestPath not found: $candidate" }
  $tests = @((Resolve-Path $candidate).Path)
}

Write-Host "== Clean contract run ==" -ForegroundColor Cyan
Write-Host ("Backend: " + $backend)
Write-Host ("Port:    " + $Port)
Write-Host ("Tests:   " + $tests.Count)

$progress = Join-Path $backend "src\data\progress.json"

$failed = 0
foreach ($t in $tests) {
  Write-Host ""
  Write-Host ("--- Running: " + (Split-Path $t -Leaf)) -ForegroundColor Yellow

  # Reset persistent state
  if (Test-Path $progress) {
    Remove-Item $progress -Force
    Write-Host "OK: Removed progress.json"
  }

  # Ensure port free, start backend, wait health
  Stop-PortProcess -P $Port

  $dev = Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command",
    "cd `"$backend`"; npm run dev"
  )

  try {
    if (-not (Wait-Health200 -P $Port -WaitSec $TimeoutSec)) {
      throw "Backend health check failed on http://localhost:$Port/health"
    }
    Write-Host "OK: Backend health=200"

& $npmExe --prefix $backend test -- --runInBand --runTestsByPath $t
    $npmExit = $LASTEXITCODE
    if ($npmExit -ne 0) {
      $failed++
      Write-Host ("FAIL: npm run test:contract:contract exited with code: {0}" -f $npmExit) -ForegroundColor Red
    }
  } catch {
    $failed++
    Write-Host ("FAIL: " + $_.Exception.Message) -ForegroundColor Red
  } finally {
    Stop-PortProcess -P $Port
    if ($dev -and -not $dev.HasExited) { Stop-Process -Id $dev.Id -Force -ErrorAction SilentlyContinue }
    Write-Host "--- Done ---"
  }
}

if ($failed -gt 0) {
  Finish 1 ("STOP: Contract run finished with failures: {0}" -f $failed)
}

Write-Host ""
Write-Host "== All contract tests green ==" -ForegroundColor Green
Finish 0 "OK: Contract tests green."




