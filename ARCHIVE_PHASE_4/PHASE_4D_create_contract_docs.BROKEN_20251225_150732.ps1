# PHASE_4D_create_contract_docs.ps1
# Creates docs\PHASE_4_PERSISTENCE_CONTRACTS.md
# Golden rules: safe paths, sanity checks, return to project root.

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) {
    throw ("Missing required {0}: {1}" -f $label, $p)
  }
}

try {
  # --- Resolve project root as the folder containing this script ---
  $root = Split-Path -Parent $MyInvocation.MyCommand.Path
  Set-Location $root

  # --- Required known paths ---
  $docsDir = Join-Path $root "docs"
  $backendData = Join-Path $root "backend\src\data\progress.json"

  # We don't fail if progress.json isn't present yet, but we DO reference it in docs.
  # If you want to enforce it, uncomment the next line:
  # Assert-Path $backendData "backend progress file"

  # --- Ensure docs folder exists ---
  if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir | Out-Null
  }

  $outDoc = Join-Path $docsDir "PHASE_4_PERSISTENCE_CONTRACTS.md"

  # --- Build markdown lines safely (no broken here-strings) ---
  $lines = @()
  $lines += "# Phase 4 — Persistence Contracts"
  $lines += ""
  $lines += "## Purpose"
  $lines += "- Persist Daily Challenge progress to disk so it survives backend restarts."
  $lines += ""
  $lines += "## Persisted State File"
  $lines += "- **File path:** `backend\src\data\progress.json`"
  $lines += "- **Objective:** Durable state for Daily Challenge progress."
  $lines += ""
  $lines += "## Source of Truth (Canonical)"
  $lines += "- `solvedPuzzleIds` (an object/map) is the canonical persisted structure."
  $lines += "- `solvedIds` (an array) is a **derived** convenience list."
  $lines += ""
  $lines += "## Invariants"
  $lines += "- `solved` == number of keys in `solvedPuzzleIds`."
  $lines += "- `solvedIds` must always be derived from keys of `solvedPuzzleIds` (order not important)."
  $lines += "- If both exist on disk, they must match."
  $lines += ""
  $lines += "## Expected JSON Shape (example)"
  $lines += "```json"
  $lines += "{"
  $lines += '  "total": 3,'
  $lines += '  "solved": 1,'
  $lines += '  "solvedToday": 1,'
  $lines += '  "totalSolved": 1,'
  $lines += '  "streak": 0,'
  $lines += '  "solvedIds": ["demo-1"],'
  $lines += '  "solvedPuzzleIds": {'
  $lines += '    "demo-1": true'
  $lines += "  }"
  $lines += "}"
  $lines += "```"
  $lines += ""
  $lines += "## API Contract Notes"
  $lines += "- `POST /progress/reset` resets in-memory + persisted progress."
  $lines += "- `POST /progress/solve` records solve + updates persisted file."
  $lines += "- `GET /progress` returns progress for UI."
  $lines += ""
  $lines += "## Nodemon Watch / Ignore"
  $lines += "- If nodemon restarts repeatedly, ensure it ignores changes to `src\\data\\progress.json`."
  $lines += "- Example ignore entries:"
  $lines += "```json"
  $lines += '{ "ignore": ["data/progress.json", "src/data/progress.json"] }'
  $lines += "```"
  $lines += ""
  $lines += "## Sanity Checks"
  $lines += "- After solve, confirm:"
  $lines += "  - API shows `solvedIds` includes the puzzle id"
  $lines += "  - Disk file contains matching `solvedPuzzleIds` + derived `solvedIds`"
  $lines += ""

  # --- Write doc ---
  $lines | Set-Content -Path $outDoc -Encoding UTF8

  Write-Host ("PHASE_4D GREEN: wrote {0}" -f $outDoc) -ForegroundColor Green
  Write-Host ("Returned to project root: {0}" -f $root) -ForegroundColor Green

} catch {
  Write-Host ("PHASE_4D ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
}
