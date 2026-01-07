# PHASE 5 — Game Expansion Contracts (Do Not Break Phase 4)

## Status
- Phase 4 is frozen and must not be modified.
- This document defines Phase 5 rules BEFORE implementation.

## Phase 4 Frozen Boundary (Non-Negotiable)
Do NOT modify:
- backend/src/**
- frontend/src/**
- ARCHIVE_PHASE_4/**

## Objective (Phase 5)
Expand the game with more puzzles and/or categories WITHOUT changing persistence rules or progress storage format.

## System of Record
- On disk: backend/src/data/progress.json
- Canonical persisted structure: solvedPuzzleIds (object/map)
- Derived view: solvedIds (array) MUST be derived from solvedPuzzleIds keys

## Puzzle Identity Contract
- Every puzzle MUST have a stable unique puzzleId (string).
- puzzleId MUST NOT change once released.

## API Usage Contract
- UI marks solved using:
  - POST /progress/solve { "puzzleId": "<id>" }
- UI reads progress using:
  - GET /progress

## UI Contract (No assumptions)
- UI MUST NOT hardcode total puzzle count.
- Total puzzle count should come from puzzle list length (front-end puzzle registry) or backend puzzles endpoint (if later added).

## Failure Conditions
- Duplicate puzzleId causes corrupted progress.
- UI assumes fixed puzzle count (breaks completion banner & progress screen).
- Any Phase 4 file edited (violates freeze rule).

## Testing Contract (Phase 5)
Minimum tests after any Phase 5 change:
1) GET /health returns 200
2) GET /progress returns 200
3) Solve one known puzzleId, then restart backend
4) GET /progress still includes that puzzleId
5) UI daily page reflects solved state correctly
