"use strict";

const adapter = require("./phase20_leaderboard_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const bronze = adapter.main({
        sessionId: "session-601",
        matchId: "match-601",
        playerName: "Noah",
        score: 600,
        difficulty: "easy",
        category: "history"
    });

    const silver = adapter.main({
        sessionId: "session-602",
        matchId: "match-602",
        playerName: "Maya",
        score: 900,
        difficulty: "medium",
        category: "science"
    });

    assert(bronze.rankBucket === "bronze", "bronze rank mismatch");
    assert(silver.rankBucket === "silver", "silver rank mismatch");
    assert(bronze.leaderboardState === "recorded", "bronze leaderboardState mismatch");
    assert(silver.leaderboardState === "recorded", "silver leaderboardState mismatch");

    console.log("OK PHASE20 LEADERBOARD RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
