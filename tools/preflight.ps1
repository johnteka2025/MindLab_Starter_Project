[CmdletBinding()]
param(
  [switch]$AllowDirty
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function StopNow([string]$msg) {
  Write-Host "=== PREFLIGHT STOP ===" -ForegroundColor Red
  Write-Host $msg -ForegroundColor Red
  Write-Host "=== STATUS (porcelain) ===" -ForegroundColor Yellow
  git status --porcelain | Out-Host
  Write-Host "=== STAGED (cached) ===" -ForegroundColor Yellow
  git diff --name-only --cached | Out-Host
  throw $msg
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $repoRoot

Write-Host "== Preflight ==" -ForegroundColor Cyan
Write-Host ("RepoRoot: {0}" -f $repoRoot)

# Repo dirty evaluation (bootstrapping safe)
$dirtyLines = @(git status --porcelain)

if (-not $AllowDirty -and $dirtyLines.Count -gt 0) {
  # Accept ONLY dirt caused by tools/preflight.ps1 (bootstrapping rule)
  $allowed = @(" M tools/preflight.ps1", "?? tools/preflight.ps1")
  $unexpected = @($dirtyLines | Where-Object { $allowed -notcontains $_ })
  if ($unexpected.Count -gt 0) {
    StopNow "STOP: Repo not clean (unexpected changes present)."
  } else {
    Write-Host "NOTE: Repo dirty only due to tools/preflight.ps1 (allowed for bootstrapping)." -ForegroundColor Yellow
  }
}

# Required paths (from your validated workflow)
$req = @(
  (Join-Path $repoRoot "tools\run_contract_canonical_v3.ps1"),
  (Join-Path $repoRoot "backend\node_modules\.bin\jest.cmd")
)

foreach ($p in $req) {
  if (-not (Test-Path $p)) {
    StopNow ("STOP: Missing required path: {0}" -f $p)
  }
}

# Parse checks (must never lie)
$psFiles = @(
  (Join-Path $repoRoot "tools\run_contract_canonical_v3.ps1"),
  (Join-Path $repoRoot "tools\preflight.ps1")
)

foreach ($f in $psFiles) {
  if (-not (Test-Path $f)) { StopNow ("STOP: Missing file for parse-check: {0}" -f $f) }
  $t=$null; $e=$null
  [System.Management.Automation.Language.Parser]::ParseFile($f,[ref]$t,[ref]$e) | Out-Null
  if ($e -and $e.Count -gt 0) {
    $e | Format-Table Message,Extent -AutoSize | Out-Host
    StopNow ("STOP: Parse errors in {0}" -f $f)
  }
}

Write-Host "OK: preflight passed" -ForegroundColor Green
