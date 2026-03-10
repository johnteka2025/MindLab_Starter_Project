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

module.exports = contracts;

if (require.main === module) {
    console.log(JSON.stringify(contracts, null, 2));
}
