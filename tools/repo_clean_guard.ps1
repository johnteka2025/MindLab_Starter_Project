Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Fail { param([string]$Message) Write-Host $Message -ForegroundColor Red; $global:LASTEXITCODE=1 }
function Stop-Ok   { param([string]$Message) Write-Host $Message -ForegroundColor Green; $global:LASTEXITCODE=0 }

try {
  if (-not (Test-Path ".git")) { Stop-Fail "STOP: Not at repo root (.git missing)."; exit $global:LASTEXITCODE }

  $s = @(git status --porcelain)
  if ($s.Count -eq 0) { Stop-Ok "OK: Repo clean."; exit $global:LASTEXITCODE }

  Write-Host "=== REPO NOT CLEAN (porcelain) ===" -ForegroundColor Yellow
  $s | Out-Host

  $untracked = @($s | Where-Object { $_ -match '^\?\?\s+' })
  $tracked   = @($s | Where-Object { $_ -notmatch '^\?\?\s+' })

  if ($tracked.Count -gt 0) { Stop-Fail "STOP: Tracked changes exist. Resolve via DISCARD or SINGLE CLEAN COMMIT."; exit $global:LASTEXITCODE }
  if ($untracked.Count -gt 0) { Stop-Fail "STOP: Untracked files exist. Resolve via REMOVE (git clean -fd) or STAGE+COMMIT intended files."; exit $global:LASTEXITCODE }

  Stop-Fail "STOP: Repo not clean (unknown reason)."
  exit $global:LASTEXITCODE
}
catch {
  Write-Host ("STOP: repo_clean_guard crashed: {0}" -f $_.Exception.Message) -ForegroundColor Red
  $global:LASTEXITCODE=1
  exit $global:LASTEXITCODE
}
