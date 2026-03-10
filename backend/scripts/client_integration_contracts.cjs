"use strict";

const contracts = {
    gameSession: {
        endpoint: "/game/game-session",
        method: "POST"
    },
    multiplayerMatch: {
        endpoint: "/game/multiplayer-match",
        method: "POST"
    },
    aiDifficultyCalibration: {
        endpoint: "/game/ai-difficulty-calibration",
        method: "POST"
    }
};

console.log(JSON.stringify(contracts, null, 2));
