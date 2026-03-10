"use strict";

function calibrateDifficulty(input) {
    const payload = input || {};
    const playerAccuracy = Number(payload.playerAccuracy || 0);
    const responseTimeMs = Number(payload.responseTimeMs || 0);

    let recommendedDifficulty = "medium";

    if (playerAccuracy >= 85 && responseTimeMs <= 8000) {
        recommendedDifficulty = "hard";
    } else if (playerAccuracy <= 50) {
        recommendedDifficulty = "easy";
    }

    return {
        playerAccuracy,
        responseTimeMs,
        recommendedDifficulty,
        ok: true
    };
}

module.exports = { calibrateDifficulty };
