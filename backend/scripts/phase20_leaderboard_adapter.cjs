"use strict";

function assertString(value, fieldName) {
    if (typeof value !== "string" || value.trim() === "") {
        throw new Error(fieldName + " must be a non-empty string");
    }
}

function assertNumber(value, fieldName) {
    if (typeof value !== "number" || Number.isNaN(value)) {
        throw new Error(fieldName + " must be a valid number");
    }
}

function main(input) {
    const payload = input || {
        sessionId: "session-600",
        matchId: "match-600",
        playerName: "Maya",
        score: 1250,
        difficulty: "hard",
        category: "science"
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.playerName, "playerName");
    assertString(payload.difficulty, "difficulty");
    assertString(payload.category, "category");
    assertNumber(payload.score, "score");

    const result = {
        ok: true,
        leaderboardEntryId: "leader-" + payload.matchId,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        playerName: payload.playerName,
        score: payload.score,
        difficulty: payload.difficulty,
        category: payload.category,
        rankBucket: payload.score >= 1200 ? "gold" : payload.score >= 800 ? "silver" : "bronze",
        leaderboardState: "recorded",
        recordedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
