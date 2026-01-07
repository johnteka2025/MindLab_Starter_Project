# PATCH_05_UPGRADE_SANITY_PHASE5_SAFE_APPEND.ps1
# Inserts Phase 5 difficulty filtering checks into RUN_FULLSTACK_SANITY.ps1
# Strategy:
# 1) If "Full-stack sanity completed" exists, insert just BEFORE it.
# 2) Else append to end-of-file.
# Golden rules: canonical paths, backup first, idempotent marker, UTF-8 no BOM.

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$sanity = Join-Path $root "RUN_FULLSTACK_SANITY.ps1"

Write-Host "ROOT:   $root"
Write-Host "SANITY: $sanity"

if(!(Test-Path $root)) { throw "STOP: Project root not found: $root" }
if(!(Test-Path $sanity)) { throw "STOP: Missing sanity script: $sanity" }

$before = Get-Content $sanity -Raw

# Idempotency guard
if($before -match "PHASE 5 CHECKS\s*\(difficulty filtering\)") {
  throw "STOP: Phase 5 checks already present in RUN_FULLSTACK_SANITY.ps1 (no change)."
}

# Backup first
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$sanity.bak_$ts"
Copy-Item $sanity $bak -Force
Write-Host "OK: Backup created -> $bak"

$block = @"
# ------------------------------
# PHASE 5 CHECKS (difficulty filtering)
# ------------------------------
try {
  # Use existing backendUrl if the script defines it; else default
  if (-not (Get-Variable -Name backendUrl -ErrorAction SilentlyContinue)) {
    `$backendUrl = 'http://localhost:8085'
  }

  function Get-HttpStatus([string]`$url) {
    try {
      `$r = Invoke-WebRequest `$url -UseBasicParsing -TimeoutSec 10
      return [int]`$r.StatusCode
    } catch {
      `$resp = `$_.Exception.Response
      if(`$resp -and `$resp.StatusCode) {
        return [int]`$resp.StatusCode.value__
      }
      throw
    }
  }

  `$s = Get-HttpStatus (`$backendUrl + '/difficulty')
  if(`$s -ne 200){ throw ('STOP: /difficulty expected 200 but got ' + `$s) }
  Write-Host 'OK: /difficulty -> 200'

  foreach(`$d in @('easy','medium','hard')){
    `$s2 = Get-HttpStatus (`$backendUrl + '/puzzles?difficulty=' + `$d)
    if(`$s2 -ne 200){ throw ('STOP: /puzzles?difficulty=' + `$d + ' expected 200 but got ' + `$s2) }
  }
  Write-Host 'OK: /puzzles?difficulty=easy|medium|hard -> 200'

  `$sBad = Get-HttpStatus (`$backendUrl + '/puzzles?difficulty=INVALID')
  if(`$sBad -ne 400){ throw ('STOP: /puzzles?difficulty=INVALID expected 400 but got ' + `$sBad) }
  Write-Host 'OK: /puzzles?difficulty=INVALID -> 400 (expected)'
} catch {
  throw
}

"@

# Preferred insertion anchor (stable): before the final completion message
$anchor = "Full-stack sanity completed"
if($before -match [regex]::Escape($anchor)) {
  # Insert BEFORE the first occurrence of the anchor line
  $pattern = "(?m)^(.*$([regex]::Escape($anchor)).*)$"
  # More robust: split by lines and insert right before the line that contains anchor
  $lines = $before -split "(`r`n|`n|`r)"
  $out = New-Object System.Collections.Generic.List[string]
  $inserted = $false

  foreach($ln in $lines){
    if(-not $inserted -and $ln -like "*$anchor*"){
      $out.Add("")
      $out.Add($block.TrimEnd())
      $out.Add("")
      $inserted = $true
    }
    $out.Add($ln)
  }

  if(-not $inserted){
    throw "STOP: Anchor was detected by regex but not found in line iteration. Refusing to patch."
  }

  $after = ($out -join "`r`n")
  Write-Host "OK: Inserted Phase 5 block before '$anchor'."
} else {
  # Safe fallback: append to end-of-file
  $after = $before.TrimEnd() + "`r`n`r`n" + $block.TrimEnd() + "`r`n"
  Write-Host "OK: Anchor '$anchor' not found. Appended Phase 5 block at end-of-file."
}

# Integrity check: marker appears exactly once
$markerCount = ([regex]::Matches($after, "PHASE 5 CHECKS\s*\(difficulty filtering\)")).Count
if($markerCount -ne 1){
  throw "STOP: Patch integrity failed (marker count = $markerCount). Refusing to write."
}

# Write UTF-8 no BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($sanity, $after, $utf8NoBom)

Write-Host "OK: RUN_FULLSTACK_SANITY.ps1 upgraded with Phase 5 checks."
Write-Host "NEXT: Run: powershell -NoProfile -ExecutionPolicy Bypass -File `"$sanity`""
