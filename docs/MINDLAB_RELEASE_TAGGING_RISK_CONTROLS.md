# MindLab Release Tagging Risk Controls

Approved scope: Release tagging planning
Repository root: C:\Projects\MindLab_Starter_Project
QA notes root: C:\Projects\MindLab_QA_Notes

## Strict Risk Controls

- Do not create Git tags during planning.
- Do not create release branches during planning.
- Do not deploy during planning.
- Do not submit store listings during planning.
- Do not change package files during planning.
- Do not change backend runtime code during planning.
- Do not change frontend runtime code during planning.
- Do not commit API keys, tokens, certificates, passwords, or credentials.
- Do not commit .env files.
- Do not commit frontend build output.

## Repository Safety Controls

- Start every script in C:\Projects\MindLab_Starter_Project.
- End every script in C:\Projects\MindLab_Starter_Project.
- Validate repository root before repository action.
- Validate .git before Git action.
- Capture branch, commit, and tag count before validation.
- Restore runtime-mutated files before dirty-state checks.
- Stop if unexpected repository changes appear.
- Stop if staged files include anything outside approved planning docs.

## Future Release Controls

- Future tag creation must be performed only after explicit approval.
- Future tag creation must occur only on a clean repository.
- Future tag creation must reference the final validated commit.
- Future release notes must map to the validated commit.
- Future rollback instructions must be documented before release.

## PASS Tokens

PASS: RELEASE_TAGGING_RISK_CONTROLS_CREATED
PASS: NO_TAG_OR_BRANCH_CREATION_ALLOWED
PASS: NO_RUNTIME_OR_PACKAGE_CHANGES_ALLOWED
PASS: FUTURE_RELEASE_TAGGING_IMPLEMENTATION_REQUIRES_SEPARATE_APPROVAL
