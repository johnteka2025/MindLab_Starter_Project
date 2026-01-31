[CmdletBinding()]
param(
  [int]$Port = 3000,
  [int]$HealthTimeoutSeconds = 25
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$backend  = Join-Path $repoRoot "backend"
if (-not (Test-Path $backend)) { throw "STOP: backend folder missing." }

$npm  = (Get-Command npm.cmd  -ErrorAction Stop).Source

# Ensure deps (jest presence is our cheap proxy)
$jest = Join-Path $backend "node_modules\.bin\jest.cmd"
if (-not (Test-Path $jest)) {
  Push-Location $backend
  & $npm ci
  $code = $LASTEXITCODE
  Pop-Location
  if ($code -ne 0) { throw "STOP: npm ci failed while preparing backend." }
}

# Logging + PID file
$logDir  = Join-Path $env:TEMP "mindlab_contract_logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logOut  = Join-Path $logDir ("backend_contract_{0}.out.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$logErr  = Join-Path $logDir ("backend_contract_{0}.err.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$pidFile = Join-Path $logDir "backend_contract.pid"

# Set env for server
$env:PORT = "$Port"
$env:NODE_ENV = "test"

# Start server via npm start
$p = Start-Process -FilePath $npm -ArgumentList @("--prefix",$backend,"start") -PassThru -WindowStyle Hidden `
  -RedirectStandardOutput $logOut -RedirectStandardError $logErr

Set-Content -Encoding ASCII -Path $pidFile -Value $p.Id

# Wait for /health
$base = "http://127.0.0.1:$Port"
$deadline = (Get-Date).AddSeconds($HealthTimeoutSeconds)

do {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri "$base/health" -TimeoutSec 2
    if ($r.StatusCode -eq 200) { break }
  } catch {}
  Start-Sleep -Milliseconds 400
} while ((Get-Date) -lt $deadline)

try {
  $r2 = Invoke-WebRequest -UseBasicParsing -Uri "$base/health" -TimeoutSec 2
  if ($r2.StatusCode -ne 200) { throw "not-200" }
} catch {
  try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
  throw "STOP: Backend not healthy on $base. LOGS: $logOut ; $logErr"
}

Write-Host ("OK: Backend ready: {0}" -f $base) -ForegroundColor Green
Write-Host ("PID: {0}" -f $p.Id) -ForegroundColor Cyan
Write-Host ("PIDFILE: {0}" -f $pidFile) -ForegroundColor Cyan

Write-Host ("LOG_OUT: {0}" -f $logOut) -ForegroundColor Cyan
Write-Host ("LOG_ERR: {0}" -f $logErr) -ForegroundColor CyanWrite-Host ("LOG: {0}" -f $logFile) -ForegroundColor Cyan

