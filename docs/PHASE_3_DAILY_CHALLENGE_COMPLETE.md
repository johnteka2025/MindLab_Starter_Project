# Phase 3 â€“ Daily Challenge Complete (Baseline)
Date: 2025-12-25

## Current Status
- Backend: GREEN
- Frontend: GREEN
- Smoke tests: GREEN

## Canonical URLs
- Frontend home: http://localhost:5177/app
- Daily challenge: http://localhost:5177/app/daily
- Progress page: http://localhost:5177/app/progress

## Backend API Contract (Source of Truth)
- GET  /health
  - 200 -> { status: "ok", uptime: number }
- GET  /puzzles
  - 200 -> [ { id, question, options?, correctIndex? } ... ]
- GET  /progress
  - 200 -> { total: number, solved: number, solvedIds: string[] }
- POST /progress/solve
  - Body: { puzzleId: string }
  - 200 -> { ok: true, puzzleId, progress: { total, solved, solvedToday, totalSolved, streak, solvedIds } }
- POST /progress/reset
  - 200 -> { ok: true, total, solved, solvedIds: [] }

## UI Rules (Must Hold)
- Backend is the single source of truth for progress.
- Solved puzzles must not double-count (solvedIds prevents this).
- Daily completion banner appears only when:
  - solved === total
- Status label states:
  - Not started: solved === 0
  - In progress: solved > 0 and solved < total
  - Complete: solved === total

## Notes
- Any future changes must preserve the contract above.
- Golden rule: Always inspect files (Get-Content) before modifying. No guessing.
