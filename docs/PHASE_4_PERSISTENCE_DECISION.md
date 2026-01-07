# Phase 4 â€” Persistence Decision (MindLab)

Date: 2025-12-25

## Goal
Persist daily progress and solved puzzle IDs across server restarts, without breaking the current API contract.

## Current State (Baseline)
- Backend keeps progress in memory (global store).
- Endpoints used by frontend:
  - GET /puzzles
  - GET /progress
  - POST /progress/solve
  - POST /progress/reset
- Frontend shows solved markers + completion banner when solved == total.

## Options

### Option A â€” JSON File Persistence (Recommended for Phase 4B)
**What it is:** Save progress to a local JSON file (e.g., backend/src/data/progress.json).

**Pros**
- Fast to implement and test.
- No DB required.
- Works everywhere (dev, demo).

**Cons**
- Not multi-user / not scalable.
- Needs file permissions.
- Must avoid corrupt writes (atomic write or debounce saves).

**Acceptance Criteria**
- Restart backend â†’ progress state is restored.
- /progress returns correct solvedIds / solved counts.
- /progress/reset sets state to 0 and persists.
- No UI regressions (daily + progress pages still green).

### Option B â€” Postgres Persistence
**What it is:** Store progress in a DB table.

**Pros**
- Strongest long-term solution.
- Multi-user possible.

**Cons**
- More setup + migrations.
- More moving parts for local runs.

## Decision
Chosen option for Phase 4B: **Option A â€” JSON File Persistence**

## Contract / Rules
- JSON persistence must not change existing endpoints.
- Must not break run_everything_sanity.ps1.
- Must include backup + sanity checks.
- Must be reversible (restore from backup).

