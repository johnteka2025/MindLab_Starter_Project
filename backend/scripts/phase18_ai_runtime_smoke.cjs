"use strict";

const adapter = require("./phase18_ai_runtime_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-400",
        matchId: "match-400",
        playerAccuracy: 90,
        responseTimeMs: 6800,
        streakCount: 4,
        currentDifficulty: "medium"
    });

    assert(result.ok === true, "ai runtime ok mismatch");
    assert(result.sessionId === "session-400", "sessionId mismatch");
    assert(result.matchId === "match-400", "matchId mismatch");
    assert(result.currentDifficulty === "medium", "currentDifficulty mismatch");
    assert(result.recommendedDifficulty === "hard", "recommendedDifficulty mismatch");
    assert(result.reconcileState === "ready_for_runtime", "reconcileState mismatch");

    console.log("OK PHASE18 AI RUNTIME SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
