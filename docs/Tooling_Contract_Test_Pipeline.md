# Tooling & Contract Test Pipeline (Frozen)

## Entry Point
tools/all_tests.ps1

## Execution Order
1. Guard (forbidden tokens)
2. Preflight (repo + environment checks)
3. Unit tests (backend)
4. Contract tests (deterministic, isolated)

## Critical Tools
- tools/guard_no_pm.ps1
- tools/preflight.ps1
- tools/run_contract_clean.ps1
- tools/scan_forbidden_tokens.ps1

## Invariants
- No test may invoke npm scripts indirectly.
- npm.cmd and jest.cmd are resolved explicitly.
- Backend process lifecycle is fully controlled.

## Failure Policy
- Any failure halts execution.
- No partial success allowed.

## Status
- State: Frozen
- Date: 2026-01-25
