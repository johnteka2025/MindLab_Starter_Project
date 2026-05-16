# MindLab Hosting / Store Setup Risk Controls

Approved scope: Hosting / store setup planning
Repository root: C:\Projects\MindLab_Starter_Project
QA notes root: C:\Projects\MindLab_QA_Notes

## Strict Risk Controls

- Do not commit API keys, tokens, certificates, passwords, or credentials.
- Do not commit .env files.
- Do not commit frontend build output.
- Do not change package files during planning.
- Do not change backend runtime code during planning.
- Do not change frontend runtime code during planning.
- Do not create production hosting configuration during planning.
- Do not submit store listings during planning.
- Do not tag a release during planning.
- Do not deploy during planning.

## Repository Safety Controls

- Start every script in C:\Projects\MindLab_Starter_Project.
- End every script in C:\Projects\MindLab_Starter_Project.
- Validate repository root before repository action.
- Validate .git before Git action.
- Restore runtime-mutated files before dirty-state checks.
- Stop if unexpected repository changes appear.
- Stop if staged files include anything outside approved planning docs.

## Future Readiness Controls

- Hosting provider selection must be documented before implementation.
- Store submission requirements must be documented before submission.
- Privacy and child-safety requirements must be reviewed before publication.
- Rollback and support plans must be documented before deployment.

## PASS Tokens

PASS: HOSTING_STORE_RISK_CONTROLS_CREATED
PASS: NO_SECRETS_ALLOWED
PASS: NO_RUNTIME_OR_PACKAGE_CHANGES_ALLOWED
PASS: FUTURE_HOSTING_STORE_IMPLEMENTATION_REQUIRES_SEPARATE_APPROVAL
