# AUTO-PORT-CLEANUP: BEGIN
try {
  $cleanup = Join-Path "C:\Projects\MindLab_Starter_Project" "daily_cleanup_ports.ps1"
  if (Test-Path $cleanup) {
    Write-Host "[INFO] Auto-cleaning dev ports (5177, 8085, 9323)..." -ForegroundColor Cyan
    & powershell -NoProfile -ExecutionPolicy Bypass -File $cleanup -Ports 5177,8085,9323
  } else {
    Write-Host "[WARN] daily_cleanup_ports.ps1 not found; skipping port cleanup." -ForegroundColor Yellow
  }
} catch {
  Write-Host "[WARN] Port cleanup failed (continuing anyway): $($_.Exception.Message)" -ForegroundColor Yellow
}
# AUTO-PORT-CLEANUP: END

# phase_2_2E_one_command_fullcheck.ps1
# One-command fullcheck: backend + frontend + unit + E2E(local) + E2E(prod)
# Daily Guidelines: full code, correct paths, logs, clean stop, return to root.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendDir  = Join-Path $projectRoot "backend"
$frontendDir = Join-Path $projectRoot "frontend"

if (-not (Test-Path $projectRoot)) { Fail "Missing project root: $projectRoot" }
if (-not (Test-Path $backendDir))  { Fail "Missing backend folder: $backendDir" }
if (-not (Test-Path $frontendDir)) { Fail "Missing frontend folder: $frontendDir" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path $projectRoot "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logPath = Join-Path $logDir ("PHASE_2_2E_fullcheck_{0}.log" -f $stamp)

$startDir = Get-Location

$backendProc = $null
$frontendProc = $null

try {
  Set-Location $projectRoot
  Say "=== Phase 2.2E: One-command fullcheck ==="
  Say ("Log: {0}" -f $logPath)

  Start-Transcript -Path $logPath -Append | Out-Null

  Say "=== 1) Backend tests ==="
  Push-Location $backendDir
  cmd.exe /c "npm test"
  if ($LASTEXITCODE -ne 0) { Fail ("Backend npm test failed (exit={0})" -f $LASTEXITCODE) }
  Pop-Location
  Ok "Backend tests GREEN"

  Say "=== 2) Frontend unit tests (CI mode) ==="
  Push-Location $frontendDir
  cmd.exe /c "npm test -- --run"
  if ($LASTEXITCODE -ne 0) { Fail ("Frontend unit tests failed (exit={0})" -f $LASTEXITCODE) }
  Pop-Location
  Ok "Frontend unit tests GREEN"

  Say "=== 3) Start backend dev server ==="
  $backendProc = Start-Process -FilePath "cmd.exe" -ArgumentList '/c', 'npm run dev' -WorkingDirectory $backendDir -PassThru -WindowStyle Normal
  Start-Sleep -Seconds 3
  if ($backendProc.HasExited) { Fail "Backend dev server exited immediately." }
  Ok ("Backend dev server started (PID={0})" -f $backendProc.Id)

  Say "=== 4) Start frontend dev server (port 5177) ==="
  $frontendProc = Start-Process -FilePath "cmd.exe" -ArgumentList '/c', 'npm run dev -- --port 5177' -WorkingDirectory $frontendDir -PassThru -WindowStyle Normal
  Start-Sleep -Seconds 3
  if ($frontendProc.HasExited) { Fail "Frontend dev server exited immediately." }
  Ok ("Frontend dev server started (PID={0})" -f $frontendProc.Id)

  Say "=== 5) Playwright E2E (LOCAL) ==="
  Push-Location $frontendDir
  cmd.exe /c "npm run test:e2e"
  if ($LASTEXITCODE -ne 0) { Fail ("Playwright LOCAL E2E failed (exit={0})" -f $LASTEXITCODE) }
  Pop-Location
  Ok "Playwright LOCAL E2E GREEN"

  Say "=== 6) Playwright E2E (PROD) ==="
  Push-Location $frontendDir
  cmd.exe /c "npm run test:e2e:prod"
  if ($LASTEXITCODE -ne 0) { Fail ("Playwright PROD E2E failed (exit={0})" -f $LASTEXITCODE) }
  Pop-Location
  Ok "Playwright PROD E2E GREEN"

  Ok "PHASE 2.2E FULLCHECK COMPLETE â€” ALL GREEN"
}
finally {
  try { Stop-Transcript | Out-Null } catch {}

  Say "=== Cleanup: stopping dev servers ==="

  if ($frontendProc -and -not $frontendProc.HasExited) {
    try { Stop-Process -Id $frontendProc.Id -Force } catch {}
    Ok ("Stopped frontend server (PID={0})" -f $frontendProc.Id)
  } else {
    Warn "Frontend server not running or already closed."
  }

  if ($backendProc -and -not $backendProc.HasExited) {
    try { Stop-Process -Id $backendProc.Id -Force } catch {}
    Ok ("Stopped backend server (PID={0})" -f $backendProc.Id)
  } else {
    Warn "Backend server not running or already closed."
  }

  Set-Location $startDir
  Say ("Returned to: {0}" -f (Get-Location).Path)
  Say ("Log saved at: {0}" -f $logPath)
  Read-Host "Press ENTER to continue"
}