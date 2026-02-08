Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Fail { param([string]$Message) Write-Host $Message -ForegroundColor Red; $global:LASTEXITCODE=1; exit $global:LASTEXITCODE }
function Stop-Ok   { param([string]$Message) Write-Host $Message -ForegroundColor Green }

try {
  if (-not (Test-Path ".git")) { Stop-Fail "STOP: Not at worktree root (.git missing)." }

  $s = @(git status --porcelain)

  # Allow only runner to be modified in worktree
  $allowed = @(
    " M tools/run_contract_clean.ps1",
    "M  tools/run_contract_clean.ps1",
    "MM tools/run_contract_clean.ps1"
  )

  $bad = @($s | Where-Object { $allowed -notcontains $_ })
  if ($bad.Count -gt 0) {
    Write-Host "=== WORKTREE STATUS (unexpected items) ===" -ForegroundColor Yellow
    $s | Out-Host
    Stop-Fail "STOP: Worktree has unexpected dirty files (only tools/run_contract_clean.ps1 may be modified)."
  }

  Stop-Ok "OK: Worktree dirty runner allowed."

  powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\preflight_no_backend_contracts.ps1"
  $code = $LASTEXITCODE
  Write-Host ("Worktree preflight exit code => {0}" -f $code) -ForegroundColor Yellow
  if ($code -ne 0) { Stop-Fail "STOP: Preflight failed in worktree. Fix printed STOP line." }

  $global:LASTEXITCODE = 0
  exit $global:LASTEXITCODE
}
catch {
  Write-Host ("STOP: worktree_preflight crashed: {0}" -f $_.Exception.Message) -ForegroundColor Red
  $global:LASTEXITCODE = 1
  exit $global:LASTEXITCODE
}
