# MindLab Runbook

## Required Working Directory

All scripts must start and end in:

`C:\Projects\MindLab_Starter_Project`

## QA Evidence Directory

External QA evidence must be stored in:

`C:\Projects\MindLab_QA_Notes`

Do not commit QA notes unless a future scope explicitly changes that rule.

## Clean-State Procedure

Run before and after validation or documentation work:

1. Restore tracked runtime files:
   - `tools\backend.pid`
   - `backend\src\data\progress.json`

2. Remove runtime artifacts:
   - `backend\src\data\sessions.json`
   - `backend\src\data\answers.json`
   - `backend\src\data\scores.json`
   - `frontend\dist`
   - `frontend\build`

3. Confirm clean repository:
   - `git status --porcelain`

## Runtime URLs

- Backend: `http://localhost:8085`
- Frontend: `http://localhost:8090`

## Default Stop-State Validation

Expected final tokens:

- `STOP_NOW_FINAL_STATE_CONFIRMED`
- `NO_FURTHER_ACTION_UNTIL_NEW_APPROVED_SCOPE`

## Blocked by Default

The following actions require explicit future approval:

- Product-code changes.
- Deployment.
- Push.
- Release tag creation.
- Release tag push.
- Temporary Full Game Review repeat.
- Visual evidence gallery.
- Analytics implementation.

## Commit Rule

Commit only if approved documentation files changed.

Allowed documentation files for this scope:

- `README.md`
- `docs/RUNBOOK.md`
- `docs/RELEASE_NOTES.md`
- `docs/SUPPORT_GUIDE.md`
- `docs/QA_EVIDENCE_INDEX.md`
- `docs/FINAL_STOP_STATE.md`