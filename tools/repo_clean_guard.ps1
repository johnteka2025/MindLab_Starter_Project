Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Fail { param([string]$Message) Write-Host $Message -ForegroundColor Red; $global:LASTEXITCODE=1; return }
function Stop-Ok   { param([string]$Message) Write-Host $Message -ForegroundColor Green }

try {
  if (-not (Test-Path ".git")) { Stop-Fail "STOP: Not at repo root (.git missing)."; return }

  $s = @(git status --porcelain)
  if ($s.Count -eq 0) { Stop-Ok "OK: Repo clean."; $global:LASTEXITCODE=0; return }

  Write-Host "=== REPO NOT CLEAN (porcelain) ===" -ForegroundColor Yellow
  $s | Out-Host

  $untracked = @($s | Where-Object { $_ -match '^\?\?\s+' })
  $tracked   = @($s | Where-Object { $_ -notmatch '^\?\?\s+' })

  if ($tracked.Count -gt 0) {
    Stop-Fail "STOP: Tracked changes exist. Resolve via TASK 0B (commit) or TASK 0A (discard tracked)."
    return
  }

  if ($untracked.Count -gt 0) {
    Stop-Fail "STOP: Untracked files exist. Resolve via TASK 0C (remove) or TASK 0B (stage+commit)."
    return
  }

  Stop-Fail "STOP: Repo not clean for unknown reason."
}
catch {
  Write-Host ("STOP: repo_clean_guard crashed: {0}" -f $_.Exception.Message) -ForegroundColor Red
  $global:LASTEXITCODE = 1
}
