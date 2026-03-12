"use strict";

const adapter = require("./phase18_ai_runtime_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const lowSkill = adapter.main({
        sessionId: "session-401",
        matchId: "match-401",
        playerAccuracy: 45,
        responseTimeMs: 12000,
        streakCount: 0,
        currentDifficulty: "medium"
    });

    const steadySkill = adapter.main({
        sessionId: "session-402",
        matchId: "match-402",
        playerAccuracy: 72,
        responseTimeMs: 8500,
        streakCount: 2,
        currentDifficulty: "medium"
    });

    assert(lowSkill.recommendedDifficulty === "easy", "low skill difficulty mismatch");
    assert(steadySkill.recommendedDifficulty === "medium", "steady skill difficulty mismatch");
    assert(lowSkill.reconcileState === "ready_for_runtime", "low skill reconcileState mismatch");
    assert(steadySkill.reconcileState === "ready_for_runtime", "steady skill reconcileState mismatch");

    console.log("OK PHASE18 DIFFICULTY RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
