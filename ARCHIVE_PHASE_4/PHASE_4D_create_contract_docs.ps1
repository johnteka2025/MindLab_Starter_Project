# PHASE_4D_create_contract_docs.ps1
# Purpose: Write Phase 4 Persistence Contracts doc to docs\PHASE_4_PERSISTENCE_CONTRACTS.md
# Golden Rule: always run from project root and return to project root

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw ("Missing required {0}: {1}" -f $label, $p) }
}

$root = "C:\Projects\MindLab_Starter_Project"
Set-Location $root

try {
  # Required project landmarks
  Assert-Path "$root\backend\src\server.cjs" "backend entry"
  Assert-Path "$root\backend\src\data\progress.json" "persisted progress file"
  Assert-Path "$root\backend\nodemon.json" "nodemon config"
  Assert-Path "$root\docs" "docs folder"

  $outDoc = "$root\docs\PHASE_4_PERSISTENCE_CONTRACTS.md"

  # Single-quoted here-string: nothing inside is parsed; markdown stays markdown.
  $md = @'
# Phase 4 — Persistence Contracts

## Objective
Persist Daily Challenge progress so it survives backend restarts, without causing nodemon restart loops.

## Data Contract
**Persisted state file:** `backend\src\data\progress.json`  
**Purpose:** Durable state for Daily Challenge progress (survives server restart)

## Source of Truth (Invariant)
- `solvedPuzzleIds` is the canonical persisted structure.
- `solvedIds` on disk MUST always be derived from the keys of `solvedPuzzleIds`.

### Invariant Rules
- `solved` equals the count of keys in `solvedPuzzleIds`.
- `solvedIds` equals `Object.keys(solvedPuzzleIds)` (order not important).
- `total` equals the number of puzzles returned by `/puzzles`.

## Expected JSON Shape (example)
```json
{
  "total": 3,
  "solved": 1,
  "solvedToday": 1,
  "totalSolved": 1,
  "streak": 0,
  "solvedIds": ["demo-1"],
  "solvedPuzzleIds": {
    "demo-1": true
  }
}
