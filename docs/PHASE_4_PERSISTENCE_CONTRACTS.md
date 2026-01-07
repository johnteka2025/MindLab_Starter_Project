\# Phase 4 – Persistence Contracts



\## Canonical State File

backend/src/data/progress.json



\## Source of Truth

\- solvedPuzzleIds is the ONLY persisted truth

\- solvedIds must always be derived from solvedPuzzleIds



\## Invariants

\- solved === count(keys(solvedPuzzleIds))

\- solvedIds === Object.keys(solvedPuzzleIds)

\- Disk state must survive server restart

\- Nodemon must ignore progress.json



\## API Contracts



\### GET /progress

Returns:

\- total

\- solved

\- solvedIds



\### POST /progress/reset

\- Clears solvedPuzzleIds

\- Resets counters



\### POST /progress/solve

\- Adds puzzleId to solvedPuzzleIds

\- Persists to disk immediately



\## Verified On

Date: 2025-12-25

Status: GREEN



