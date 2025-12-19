# fix_phase_2_2E_wire_cleanup.ps1
# Purpose: Wire daily_cleanup_ports.ps1 into phase_2_2E_one_command_fullcheck.ps1 safely.
# Rules: backup-first, minimal change, parse-check, idempotent.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$targetPath  = Join-Path $projectRoot "phase_2_2E_one_command_fullcheck.ps1"
$cleanupPath = Join-Path $projectRoot "daily_cleanup_ports.ps1"

Info "ProjectRoot : $projectRoot"
Info "Target      : $targetPath"
Info "Cleanup     : $cleanupPath"

# ---- Path verification (NO guessing) ----
if (-not (Test-Path $projectRoot)) { Fail "Project root not found: $projectRoot" }
if (-not (Test-Path $targetPath))  { Fail "Target script not found: $targetPath" }
if (-not (Test-Path $cleanupPath)) { Fail "Cleanup script not found: $cleanupPath" }

# ---- Backup target (required) ----
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = Join-Path $projectRoot ("backups\manual_edits\PHASE_2_2E_WIRE_CLEANUP_{0}" -f $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$backupPath = Join-Path $backupDir "phase_2_2E_one_command_fullcheck.ps1.BEFORE"
Copy-Item -Force -Path $targetPath -Destination $backupPath
Ok "Backup created: $backupPath"

# ---- Read target ----
$raw = Get-Content -Raw -Path $targetPath -Encoding UTF8

# ---- Remove any existing AUTO-PORT-CLEANUP block (so we can replace cleanly) ----
$pattern = "(?ms)^\s*#\s*AUTO-PORT-CLEANUP:\s*BEGIN\s*.*?^\s*#\s*AUTO-PORT-CLEANUP:\s*END\s*\r?\n?"
$rawNoBlock = [regex]::Replace($raw, $pattern, "")

# ---- Correct cleanup block (IMPORTANT: in-process call, array stays an array) ----
$insertLines = @(
  "# AUTO-PORT-CLEANUP: BEGIN"
  "try {"
  "  `$cleanup = Join-Path `"C:\Projects\MindLab_Starter_Project`" `"daily_cleanup_ports.ps1`""
  "  if (Test-Path `$cleanup) {"
  "    Write-Host `"[INFO] Auto-cleaning dev ports (5177, 8085, 9323)...`" -ForegroundColor Cyan"
  "    & `$cleanup -Ports @(5177,8085,9323) -Force"
  "  } else {"
  "    Write-Host `"[WARN] daily_cleanup_ports.ps1 not found; skipping port cleanup.`" -ForegroundColor Yellow"
  "  }"
  "} catch {"
  "  Write-Host `"[WARN] Port cleanup failed (continuing anyway): `$(`$_.Exception.Message)`" -ForegroundColor Yellow"
  "}"
  "# AUTO-PORT-CLEANUP: END"
  ""
  ""
)

$insert = ($insertLines -join "`r`n")
$new = $insert + $rawNoBlock

# ---- Write target (UTF-8 no BOM) ----
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($targetPath, $new, $utf8NoBom)
Ok "Patched target (cleanup block wired at top)."

# ---- Parse check target (MUST be GREEN) ----
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($targetPath, [ref]$tokens, [ref]$errors) | Out-Null

if ($errors -and $errors.Count -gt 0) {
  Warn "Target parse errors detected. Restoring backup..."
  Copy-Item -Force -Path $backupPath -Destination $targetPath

  Write-Host "[FAIL] Parse errors:" -ForegroundColor Red
  $errors | ForEach-Object {
    Write-Host (" - {0}:{1} {2}" -f $_.Extent.StartLineNumber, $_.Extent.StartColumnNumber, $_.Message) -ForegroundColor Red
  }
  Fail "Patch aborted; target restored from backup."
}

Ok "Target parse check GREEN."
Info "Done. Next: run phase_2_2E_one_command_fullcheck.ps1 as usual."
