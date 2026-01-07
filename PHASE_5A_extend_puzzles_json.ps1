# PHASE_5A_extend_puzzles_json.ps1
# Goal: Extend the puzzle list by editing the JSON source used by GET /puzzles.
# Golden Rules:
# - Run from project root.
# - Do NOT touch ARCHIVE_PHASE_4.
# - Make a timestamped backup before writing.
# - Keep puzzleId stable + unique.

$ErrorActionPreference = "Stop"

try {
  $root = (Resolve-Path ".").Path
  Write-Host "Project root: $root" -ForegroundColor Cyan

  # Hard guard: do not operate inside archive
  if ($root -match "ARCHIVE_PHASE_4") {
    throw "Refusing to run inside ARCHIVE_PHASE_4. Run from project root."
  }

  $candidates = @(
    Join-Path $root "backend\src\index.json",
    Join-Path $root "backend\src\puzzles\index.json"
  )

  $src = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $src) {
    throw "No puzzles JSON source found. Checked: `n- $($candidates -join "`n- ")"
  }

  Write-Host "Using puzzles source: $src" -ForegroundColor Green

  $raw = Get-Content $src -Raw
  $json = $raw | ConvertFrom-Json

  # Support either:
  # 1) { puzzles: [...] }
  # 2) [ ... ]
  $puzzles =
    if ($json -is [System.Collections.IEnumerable] -and -not ($json.PSObject.Properties.Name -contains "puzzles")) {
      @($json)
    } elseif ($null -ne $json.puzzles) {
      @($json.puzzles)
    } else {
      throw "Unsupported JSON shape. Expected array or object with 'puzzles'."
    }

  # Collect existing IDs as strings
  $existingIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($p in $puzzles) {
    if ($null -eq $p.id) { continue }
    [void]$existingIds.Add([string]$p.id)
  }

  # Add new puzzles (FOLLOW YOUR EXISTING SCHEMA)
  # IMPORTANT: We will NOT assume fields. We will copy the first puzzle’s keys as a template guide.
  $template = $puzzles | Select-Object -First 1
  if (-not $template) { throw "No puzzles found in JSON; cannot template." }

  Write-Host "Template puzzle keys: $($template.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow

  # ---- EDIT HERE if your schema differs ----
  # These entries match the schema shown by /puzzles in your screenshot:
  # { id, question, options, correctIndex }
  $newPuzzles = @(
    [pscustomobject]@{
      id = 4
      question = "Which planet is known as the Red Planet?"
      options = @("Earth","Mars","Jupiter")
      correctIndex = 1
    },
    [pscustomobject]@{
      id = 5
      question = "What is 5 + 7?"
      options = @("10","11","12")
      correctIndex = 2
    }
  )
  # -----------------------------------------

  # Refuse if any new id already exists
  foreach ($np in $newPuzzles) {
    $nid = [string]$np.id
    if ($existingIds.Contains($nid)) {
      throw "Duplicate puzzle id detected: '$nid' already exists. Choose a new id."
    }
  }

  $updated = @($puzzles + $newPuzzles)

  # Write back using same top-level structure
  $outObj =
    if ($json -is [System.Collections.IEnumerable] -and -not ($json.PSObject.Properties.Name -contains "puzzles")) {
      $updated
    } else {
      $json.puzzles = $updated
      $json
    }

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = "$src.bak_phase5_$ts"
  Copy-Item $src $bak -Force
  Write-Host "Backup created: $bak" -ForegroundColor Green

  # Pretty JSON output
  $outJson = $outObj | ConvertTo-Json -Depth 20
  Set-Content -Path $src -Value $outJson -Encoding UTF8
  Write-Host "Wrote updated puzzles JSON: $src" -ForegroundColor Green

  # Sanity check count
  Write-Host ("Old count: {0}  New count: {1}" -f $puzzles.Count, $updated.Count) -ForegroundColor Cyan

  Write-Host "PHASE_5A GREEN: puzzles extended safely via JSON source." -ForegroundColor Green
}
catch {
  Write-Host ("PHASE_5A ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
}
finally {
  try {
    $root2 = (Resolve-Path ".").Path
    Write-Host "Returned to: $root2" -ForegroundColor DarkGray
  } catch {}
}
