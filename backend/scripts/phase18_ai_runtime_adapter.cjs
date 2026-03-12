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
        sessionId: "session-400",
        matchId: "match-400",
        playerAccuracy: 84,
        responseTimeMs: 7200,
        streakCount: 3,
        currentDifficulty: "medium"
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.currentDifficulty, "currentDifficulty");
    assertNumber(payload.playerAccuracy, "playerAccuracy");
    assertNumber(payload.responseTimeMs, "responseTimeMs");
    assertNumber(payload.streakCount, "streakCount");

    let recommendedDifficulty = payload.currentDifficulty;

    if (payload.playerAccuracy >= 85 && payload.responseTimeMs <= 7000 && payload.streakCount >= 3) {
        recommendedDifficulty = "hard";
    } else if (payload.playerAccuracy <= 50) {
        recommendedDifficulty = "easy";
    } else if (payload.playerAccuracy >= 60 && payload.playerAccuracy < 85) {
        recommendedDifficulty = "medium";
    }

    const result = {
        ok: true,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        currentDifficulty: payload.currentDifficulty,
        recommendedDifficulty,
        playerAccuracy: payload.playerAccuracy,
        responseTimeMs: payload.responseTimeMs,
        streakCount: payload.streakCount,
        reconcileState: "ready_for_runtime",
        updatedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
