"use strict";

const adapter = require("./phase20_leaderboard_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-600",
        matchId: "match-600",
        playerName: "Maya",
        score: 1250,
        difficulty: "hard",
        category: "science"
    });

    assert(result.ok === true, "leaderboard ok mismatch");
    assert(result.leaderboardEntryId === "leader-match-600", "leaderboardEntryId mismatch");
    assert(result.sessionId === "session-600", "sessionId mismatch");
    assert(result.matchId === "match-600", "matchId mismatch");
    assert(result.playerName === "Maya", "playerName mismatch");
    assert(result.score === 1250, "score mismatch");
    assert(result.rankBucket === "gold", "rankBucket mismatch");
    assert(result.leaderboardState === "recorded", "leaderboardState mismatch");

    console.log("OK PHASE20 LEADERBOARD SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
