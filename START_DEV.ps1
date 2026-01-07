# START_DEV.ps1
# Starts MindLab backend (8085) and frontend (5177) in separate PowerShell windows.
# Golden Rules: deterministic paths, clear outcomes, no guessing.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; exit 1 }
function Ok([string]$msg)   { Write-Host "OK: $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }

$ROOT     = "C:\Projects\MindLab_Starter_Project"
$BACKEND  = Join-Path $ROOT "backend"
$FRONTEND = Join-Path $ROOT "frontend"

if (-not (Test-Path $ROOT))     { Fail "Root missing: $ROOT" }
if (-not (Test-Path $BACKEND))  { Fail "Backend missing: $BACKEND" }
if (-not (Test-Path $FRONTEND)) { Fail "Frontend missing: $FRONTEND" }

# Port checks
$port8085 = Get-NetTCPConnection -LocalPort 8085 -ErrorAction SilentlyContinue
$port5177 = Get-NetTCPConnection -LocalPort 5177 -ErrorAction SilentlyContinue

if ($port8085) { Warn "Port 8085 already in use. Backend may already be running." }
if ($port5177) { Warn "Port 5177 already in use. Frontend may already be running." }

# Start backend in new window if port not already bound
if (-not $port8085) {
  Ok "Starting backend (npm run dev) in new window..."
  Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd `"$BACKEND`"; npm run dev"
  ) | Out-Null
} else {
  Ok "Skipping backend start because port 8085 is already bound."
}

# Start frontend in new window if port not already bound
if (-not $port5177) {
  Ok "Starting frontend (npm run dev) in new window..."
  Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd `"$FRONTEND`"; npm run dev"
  ) | Out-Null
} else {
  Ok "Skipping frontend start because port 5177 is already bound."
}

Ok "START_DEV completed. Verify with RUN_FULLSTACK_SANITY.ps1."
exit 0
