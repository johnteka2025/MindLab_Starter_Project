# PHASE_4D_create_contract_docs.ps1
# Purpose: Generate Phase 4 persistence contract documentation (no code changes).
# Golden Rules:
# - Run from project root
# - Always use absolute root
# - Always sanity check required paths
# - Always return to project root

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Path {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Label
  )
  if (-not (Test-Path -LiteralPath $Path)) {
    throw ("Missing required {0}: {1}" -f $Label, $Path)
  }
}

try {
  $root = "C:\Projects\MindLab_Starter_Project"
  Set-Location $root

  # Required paths (adjust nothing unless your project root differs)
  $backendProgress = Join-Path $root "backend\src\data\progress.json"
  $nodemonCfg      = Join-Path $root "backend\nodemon.json"
  $docsDir         = Join-Path $root "docs"
  $outDoc          = Join-Path $docsDir "PHASE_4_PERSISTENCE_CONTRACTS.md"

  Assert-Path -Path $root -Label "project root folder"
  Assert-Path -Path $backendProgress -Label "persisted state file (progress.json)"

  if (-not (Test-Path -LiteralPath $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir | Out-Null
  }

  # Build markdown safely using an array of lines (NO here-strings)
  $lines = New-Object System.Collections.Generic.List[string]

  $lines.Add("# Phase 4 — Persistence Contracts")
  $lines.Add("")
  $lines.Add("## File(s)")
  $lines.Add("")
  $lines.Add("- **Persisted state file:** `backend\src\data\progress.json`")
  $lines.Add("- **Optional nodemon config:** `backend\nodemon.json` (prevents restart loops)")
  $lines.Add("")
  $lines.Add("## Objective")
  $lines.Add("")
  $lines.Add("Persist Daily Challenge progress to disk so it **survives backend restarts** and can be restored on server boot.")
  $lines.Add("")
  $lines.Add("## Source of Truth")
  $lines.Add("")
  $lines.Add("- **Canonical persisted structure:** `solvedPuzzleIds` (object/map where keys are puzzle IDs, values true).")
  $lines.Add("- `solvedIds` on disk must be **derived from** the keys of `solvedPuzzleIds`.")
  $lines.Add("")
  $lines.Add("## Invariants (MUST always hold)")
  $lines.Add("")
  $lines.Add("- `solved` equals the count of keys in `solvedPuzzleIds`.")
  $lines.Add("- `solvedIds` equals `Object.keys(solvedPuzzleIds)` (order not important).")
  $lines.Add("- `total` equals the number of puzzles returned by `/puzzles` (for demo: 3).")
  $lines.Add("")
  $lines.Add("## Expected JSON Shape (example)")
  $lines.Add("")
  $lines.Add("```json")
  $lines.Add("{")
  $lines.Add('  "total": 3,')
  $lines.Add('  "solved": 1,')
  $lines.Add('  "solvedToday": 1,')
  $lines.Add('  "totalSolved": 1,')
  $lines.Add('  "streak": 0,')
  $lines.Add('  "solvedIds": ["demo-1"],')
  $lines.Add('  "solvedPuzzleIds": {')
  $lines.Add('    "demo-1": true')
  $lines.Add("  }")
  $lines.Add("}")
  $lines.Add("```")
  $lines.Add("")
  $lines.Add("## API Contract Expectations")
  $lines.Add("")
  $lines.Add("- `GET /progress` returns an object including `total`, `solved`, and `solvedIds`.")
  $lines.Add("- `POST /progress/reset` resets progress and persists to disk.")
  $lines.Add("- `POST /progress/solve` marks a puzzle solved and persists to disk.")
  $lines.Add("")
  $lines.Add("### Expected responses (examples)")
  $lines.Add("")
  $lines.Add("`POST /progress/reset` returns:")
  $lines.Add("```json")
  $lines.Add('{ "ok": true, "total": 3, "solved": 0, "solvedIds": [] }')
  $lines.Add("```")
  $lines.Add("")
  $lines.Add("`POST /progress/solve` returns:")
  $lines.Add("```json")
  $lines.Add('{ "ok": true, "puzzleId": "demo-1", "progress": { "total": 3, "solved": 1, "solvedToday": 1, "totalSolved": 1, "streak": 0, "solvedIds": ["demo-1"] } }')
  $lines.Add("```")
  $lines.Add("")
  $lines.Add("## Frontend Behavior Notes")
  $lines.Add("")
  $lines.Add("- Daily UI uses `/progress` to mark `[SOLVED]` labels and show completion banner.")
  $lines.Add("- Completion banner shows only when `solved == total`.")
  $lines.Add("")
  $lines.Add("## Nodemon Restart Loop Guard (optional but recommended)")
  $lines.Add("")
  $lines.Add("If persistence writes to `backend\\src\\data\\progress.json` cause nodemon restarts, add ignore rules in `backend\\nodemon.json`:")
  $lines.Add("")
  $lines.Add("```json")
  $lines.Add("{")
  $lines.Add('  "watch": ["src"],')
  $lines.Add('  "ignore": ["data/progress.json", "src/data/progress.json"]')
  $lines.Add("}")
  $lines.Add("```")
  $lines.Add("")
  $lines.Add("## Verification Checklist (PowerShell)")
  $lines.Add("")
  $lines.Add("From project root:")
  $lines.Add("```powershell")
  $lines.Add("Invoke-WebRequest http://localhost:8085/health -UseBasicParsing | Select StatusCode, Content")
  $lines.Add("Invoke-WebRequest http://localhost:8085/progress -UseBasicParsing | Select StatusCode, Content")
  $lines.Add("Get-Content .\\backend\\src\\data\\progress.json")
  $lines.Add("```")

  # Write output doc
  $lines | Set-Content -LiteralPath $outDoc -Encoding UTF8

  Write-Host ("PHASE_4D GREEN: wrote {0}" -f $outDoc) -ForegroundColor Green
  Write-Host ("Returned to project root: {0}" -f $root) -ForegroundColor Green
  Set-Location $root
}
catch {
  Write-Host ("PHASE_4D ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
}
