# Phase 5 – Game Expansion Scope

## Goals
- Add new puzzles dynamically
- Preserve existing persistence invariants
- Avoid backend state coupling

## Non-Goals
- No changes to progress.json schema
- No modifications to Phase 4 logic

## Required Contracts
- New puzzles must use unique puzzleId
- Solving must call POST /progress/solve
- Persistence logic remains unchanged

## Risks
- Duplicate puzzleIds
- UI assuming fixed puzzle count

## Mitigations
- Central puzzle registry
- Validation on puzzle load
