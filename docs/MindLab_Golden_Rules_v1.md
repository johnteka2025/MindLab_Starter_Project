# MindLab Golden Rules v1 (Frozen)

## 1. Repository Cleanliness
- Repo MUST be clean before any patch or execution.
- No script may auto-modify files without explicit intent.

## 2. Forbidden Command Tokens
- Forbidden tokens (e.g. pm) MUST NOT be executable.
- Tokens MAY exist ONLY inside:
  - guard scripts
  - scan scripts
  - comments
  - regex patterns
- Enforcement is automated via tools/scan_forbidden_tokens.ps1

## 3. Tooling as Infrastructure
- Files under tools/ are infrastructure.
- Once green, they MUST NOT be modified during feature work.

## 4. Path Safety
- All PowerShell scripts MUST resolve paths using:
  - $PSScriptRoot
- Relative paths like .tools\ or hard-coded CWD paths are forbidden.

## 5. Single Source of Truth
- All tests MUST be run via:
  - tools/all_tests.ps1
- No ad-hoc test execution is allowed.

## 6. Commit Discipline
- Commits are allowed ONLY after:
  - Guard passes
  - Preflight passes
  - Unit tests pass
  - Contract tests pass

## Status
- Version: v1
- State: Frozen
- Date: 2026-01-25
