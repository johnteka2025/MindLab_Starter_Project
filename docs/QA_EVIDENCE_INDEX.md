# MindLab QA Evidence Index

## Evidence Root

`C:\Projects\MindLab_QA_Notes`

## Required Evidence Categories

The QA notes directory should preserve evidence for:

1. Content stabilization.
2. Gameplay UI and UX polish.
3. Accessibility pass.
4. Difficulty progression balancing.
5. Persistence and session hardening.
6. Deployment readiness.
7. Release candidate closeout.
8. Final human playtest.
9. Deterministic browser/API validation.
10. Temporary Full Game Review.
11. Final stop gate.
12. Documentation polish.

## Latest Known Final Stop Gate Pattern

`temporary_full_game_review_final_stop_gate_resume_*.md`

Fallback pattern:

`final_stop_gate_after_final_human_playtest_*.md`

## Required Stop Tokens

- `STOP_NOW_FINAL_STATE_CONFIRMED`
- `NO_FURTHER_ACTION_UNTIL_NEW_APPROVED_SCOPE`

## Runtime Cleanup Targets

Tracked files to restore:

- `tools\backend.pid`
- `backend\src\data\progress.json`

Runtime files to remove:

- `backend\src\data\sessions.json`
- `backend\src\data\answers.json`
- `backend\src\data\scores.json`
- `frontend\dist`
- `frontend\build`

## Evidence Quality Gap

Functional review passed, but screenshot-level visual walkthrough evidence is not yet required unless the separate scope `Temporary Full Game Visual Evidence Gallery` is approved.