# MindLab Phase 2.0 — Invariants (Must Never Break)
Date: 2025-12-14 12:15:11

## Runtime expectations
- Frontend runs on: http://localhost:5177
- Backend runs on: http://localhost:8085

## API invariants (contract)
1) GET /health
   - Returns HTTP 200
2) GET /progress
   - Returns HTTP 200 and JSON with numeric fields:
     - total (>=0)
     - solved (>=0)
   - Must satisfy: 0 <= solved <= total
3) POST /progress/solve
   - Request JSON: { "puzzleId": <number> }
   - Returns HTTP 200 and JSON containing progress object.
   - After solving one puzzle, GET /progress.solved must not decrease.
4) Cross-page consistency
   - Daily page action "Mark Solved" must cause Progress page to reflect updated solved/total
   - Progress page must not show “Failed to fetch” when backend is healthy.

## UI invariants
- /app/daily loads and shows at least 1 puzzle item.
- /app/progress loads and shows numeric values (no fetch error).

## Notes
- If UI fails but curl passes: likely frontend base URL / proxy / fetch path issue.
- If curl fails: backend routes or CORS / server runtime issue.

