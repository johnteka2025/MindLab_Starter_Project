# phase5_scripts\PHASE_5A_extend_puzzles_index_json_v2.ps1
# Golden Rules: deterministic paths, backup first, validate, NO BOM writes, return to root.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom([string]$Path, [string]$Text) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

try {
  $scriptDir = $PSScriptRoot
  $root = Split-Path $scriptDir -Parent

  Write-Host "=== PHASE 5A v2 — Extend puzzles (index.json) ===" -ForegroundColor Cyan
  Write-Host "Project root: $root"

  $target = Join-Path $root "backend\src\puzzles\index.json"
  if (-not (Test-Path $target)) { throw "Missing target file: $target" }

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $backup = Join-Path $root ("phase5_logs\index.json.bak_phase5a_v2_{0}" -f $ts)
  Copy-Item -Force $target $backup

  # Read + parse existing
  $raw = Get-Content $target -Raw
  $puzzles = $raw | ConvertFrom-Json
  if ($null -eq $puzzles) { throw "Target JSON parsed to null (unexpected)." }
  if (-not ($puzzles -is [System.Array])) { throw "Target JSON is not an array. Expected [ ... ] at top level." }

  # Determine max numeric id
  $maxId = 0
  foreach ($p in $puzzles) {
    if ($null -ne $p.id) {
      $n = 0
      if ([int]::TryParse(($p.id.ToString()), [ref]$n)) {
        if ($n -gt $maxId) { $maxId = $n }
      }
    }
  }

  # Add exactly 3 new puzzles (edit text later, but keep ids stable)
  $new = @(
    [pscustomobject]@{
      id = $maxId + 1
      question = "Phase 5: Which planet is known as the Red Planet?"
      options = @("Earth","Mars","Jupiter")
      correctIndex = 1
    },
    [pscustomobject]@{
      id = $maxId + 2
      question = "Phase 5: What is 5 × 6?"
      options = @("11","30","56")
      correctIndex = 1
    },
    [pscustomobject]@{
      id = $maxId + 3
      question = "Phase 5: Which gas do plants primarily absorb?"
      options = @("Oxygen","Carbon Dioxide","Nitrogen")
      correctIndex = 1
    }
  )

  $updated = @()
  $updated += $puzzles
  $updated += $new

  # Write formatted JSON, NO BOM
  $jsonOut = $updated | ConvertTo-Json -Depth 10
  Write-Utf8NoBom -Path $target -Text $jsonOut

  # Validate parse again
  $raw2 = Get-Content $target -Raw
  $null = $raw2 | ConvertFrom-Json

  Write-Host "PHASE_5A_V2 GREEN: puzzles extended" -ForegroundColor Green
  Write-Host ("Target : {0}" -f $target)
  Write-Host ("Backup : {0}" -f $backup)
  Write-Host ("Count  : {0} -> {1}" -f $puzzles.Count, $updated.Count)

} catch {
  Write-Host ("PHASE_5A_V2 ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
} finally {
  Set-Location $PWD.Path | Out-Null
  # Return to project root safely if script was run from anywhere
  try { Set-Location (Split-Path $PSScriptRoot -Parent) | Out-Null } catch {}
  Write-Host ("Returned to: {0}" -f (Get-Location).Path) -ForegroundColor DarkGray
}
