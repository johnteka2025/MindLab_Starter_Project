# MindLab Validation Workflow

Repository root: C:\Projects\MindLab_Starter_Project
QA notes root: C:\Projects\MindLab_QA_Notes

## Repository Safety Rules

- Start every script in C:\Projects\MindLab_Starter_Project.
- End every script in C:\Projects\MindLab_Starter_Project.
- Validate C:\Projects\MindLab_Starter_Project before every repository action.
- Validate C:\Projects\MindLab_Starter_Project\.git before every Git action.
- Restore runtime-mutated files before dirty-state checks.
- Do not commit QA files from C:\Projects\MindLab_QA_Notes.

## Runtime Files To Exclude From Commits

- tools\backend.pid
- backend\src\data\progress.json
- backend\src\data\sessions.json
- backend\src\data\answers.json
- backend\src\data\scores.json
- frontend\dist
- frontend\build

## Commit Rules

- Stop if repository is dirty before approved changes.
- Stop if staged changes include files outside the approved scope.
- Stop if commit fails.
- Confirm repository is clean after commit.

## PASS Tokens

PASS: VALIDATION_WORKFLOW_CREATED
PASS: REPOSITORY_SAFETY_RULES_DOCUMENTED
PASS: COMMIT_SAFETY_RULES_DOCUMENTED
