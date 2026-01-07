# PATCH_05_UPGRADE_SANITY_PHASE5_FULL.ps1
# Purpose: Upgrade RUN_FULLSTACK_SANITY.ps1 to include Phase 5 checks:
# - /difficulty -> 200
# - /puzzles?difficulty=easy|medium|hard -> 200
# - /puzzles?difficulty=INVALID -> 400 (expected)
# Golden rules: canonical paths, preflight checks, backup, idempotent patch, UTF-8 no BOM write.

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$sanity = Join-Path $root "RUN_FULLSTACK_SANITY.ps1"

Write-Host "ROOT:   $root"
Write-Host "SANITY: $sanity"

if(!(Test-Path $root)) { throw "STOP: Project root not found: $root" }
if(!(Test-Path $sanity)) { throw "STOP: Missing sanity script: $sanity" }

# Read file
$before = Get-Content $sanity -Raw

# Idempotency guard: refuse to patch twice
if($before -match "PHASE 5 CHECKS\s*\(difficulty filtering\)") {
  throw "STOP: Phase 5 checks already present in RUN_FULLSTACK_SANITY.ps1 (no change)."
}

# Make a backup first
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$sanity.bak_$ts"
Copy-Item $sanity $bak -Force
Write-Host "OK: Backup created -> $bak"

# Find insertion anchor.
# Preferred: after a line that prints OK for /puzzles
# Fallback: after the first Invoke-WebRequest that hits /puzzles
$lines = $before -split "(`r`n|`n|`r)"
$idx = -1

for($i=0; $i -lt $lines.Count; $i++){
  $ln = $lines[$i]
  if($ln -match "/puzzles" -and $ln -match "OK:" ){
    $idx = $i
    break
  }
}

if($idx -lt 0){
  for($i=0; $i -lt $lines.Count; $i++){
    $ln = $lines[$i]
    if($ln -match "Invoke-WebRequest" -and $ln -match "/puzzles"){
      $idx = $i
      break
    }
  }
}

if($idx -lt 0){
  throw "STOP: Could not find a safe insertion point in RUN_FULLSTACK_SANITY.ps1 (no '/puzzles' anchor found). Refusing to patch."
}

# Phase 5 checks block to insert
$block = @(
"",
"# ------------------------------",
"# PHASE 5 CHECKS (difficulty filtering)",
"# ------------------------------",
"try {",
"  # Prefer existing backend base URL variable if present; otherwise default to localhost:8085",
"  if (-not (Get-Variable -Name backendUrl -ErrorAction SilentlyContinue)) {",
"    $backendUrl = 'http://localhost:8085'",
"  }",
"",
"  function Get-HttpStatus([string]$url) {",
"    try {",
"      $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 10",
"      return [int]$r.StatusCode",
"    } catch {",
"      # For 4xx/5xx responses, PowerShell throws; attempt to read status code",
"      $resp = $_.Exception.Response",
"      if($resp -and $resp.StatusCode) {",
"        return [int]$resp.StatusCode.value__",
"      }",
"      throw",
"    }",
"  }",
"",
"  $s = Get-HttpStatus ($backendUrl + '/difficulty')",
"  if($s -ne 200){ throw ('STOP: /difficulty expected 200 but got ' + $s) }",
"  Write-Host 'OK: /difficulty -> 200'",
"",
"  foreach($d in @('easy','medium','hard')){",
"    $s2 = Get-HttpStatus ($backendUrl + '/puzzles?difficulty=' + $d)",
"    if($s2 -ne 200){ throw ('STOP: /puzzles?difficulty=' + $d + ' expected 200 but got ' + $s2) }",
"  }",
"  Write-Host 'OK: /puzzles?difficulty=easy|medium|hard -> 200'",
"",
"  $sBad = Get-HttpStatus ($backendUrl + '/puzzles?difficulty=INVALID')",
"  if($sBad -ne 400){ throw ('STOP: /puzzles?difficulty=INVALID expected 400 but got ' + $sBad) }",
"  Write-Host 'OK: /puzzles?difficulty=INVALID -> 400 (expected)'",
"} catch {",
"  throw",
"}",
""
)

# Insert block after anchor line (idx)
$newLines = @()
$newLines += $lines[0..$idx]
$newLines += $block
if($idx + 1 -le $lines.Count - 1){
  $newLines += $lines[($idx+1)..($lines.Count-1)]
}

$after = ($newLines -join "`r`n")

# Final safety check: ensure we actually inserted the marker once
$markerCount = ([regex]::Matches($after, "PHASE 5 CHECKS\s*\(difficulty filtering\)")).Count
if($markerCount -ne 1){
  throw "STOP: Patch integrity failed (marker count = $markerCount). Refusing to write."
}

# Write UTF-8 no BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($sanity, $after, $utf8NoBom)

Write-Host "OK: RUN_FULLSTACK_SANITY.ps1 upgraded with Phase 5 checks."
Write-Host "NEXT: Run: powershell -NoProfile -ExecutionPolicy Bypass -File `"$sanity`""
