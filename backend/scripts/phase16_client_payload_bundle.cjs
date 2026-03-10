"use strict";

const bundle = {
    gameSession: {
        endpoint: "/game/game-session",
        method: "POST",
        payload: {
            player: "Maya",
            difficulty: "medium",
            question: "Q1"
        }
    },
    multiplayerMatch: {
        endpoint: "/game/multiplayer-match",
        method: "POST",
        payload: {
            matchId: "match-200",
            hostPlayer: "Maya",
            guestPlayer: "Noah",
            difficulty: "hard",
            category: "science",
            questionCount: 12
        }
    },
    aiDifficultyCalibration: {
        endpoint: "/game/ai-difficulty-calibration",
        method: "POST",
        payload: {
            playerAccuracy: 90,
            responseTimeMs: 7000
        }
    }
};

module.exports = bundle;

if (require.main === module) {
    console.log(JSON.stringify(bundle, null, 2));
}
