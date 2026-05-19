# MindLab Starter Project

MindLab is a three-age-category cognitive game project for Kids, Adults, and Seniors.

## Current State

- Mandatory game-creation work: complete.
- Current approved scope: Documentation polish.
- Repository root: `C:\Projects\MindLab_Starter_Project`.
- QA evidence root: `C:\Projects\MindLab_QA_Notes`.
- Deployment: blocked unless explicitly approved.
- Push: blocked unless explicitly approved.
- Release tagging: blocked unless explicitly approved.

## Validated Game Scope

- Kids category: complete.
- Adults category: complete.
- Seniors category: complete.
- Question presentation: passed temporary full game review.
- Score view: passed temporary full game review.
- Progress view: passed temporary full game review.
- Age-category switching: passed temporary full game review.
- Runtime or missing-file issue status: no blocker recorded in latest review.

## Local Runtime References

- Backend URL: `http://localhost:8085`
- Frontend URL: `http://localhost:8090`

## Documentation

- Runbook: `docs/RUNBOOK.md`
- Release notes: `docs/RELEASE_NOTES.md`
- Support guide: `docs/SUPPORT_GUIDE.md`
- QA evidence index: `docs/QA_EVIDENCE_INDEX.md`
- Final stop state: `docs/FINAL_STOP_STATE.md`

## Execution Rules

Use PowerShell automation only for repository changes.

Required controls:

1. Start and end in `C:\Projects\MindLab_Starter_Project`.
2. Validate `.git` before git actions.
3. Restore runtime-mutated files before clean checks.
4. Remove runtime artifacts before final clean checks.
5. Commit only when approved documentation files changed.
6. Do not deploy, push, or tag without explicit approval.

## Next Approved Scope Order

1. Documentation polish.
2. Analytics planning.
3. Hosting / store setup planning.
4. Release tagging.
5. Post-release bug triage.
6. Temporary Full Game Visual Evidence Gallery, if screenshot-level evidence is needed.

## Stop Rule

When final stop tokens are confirmed, do not continue work until one new scope is explicitly approved.