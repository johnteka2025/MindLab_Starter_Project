"use strict";

const contracts = require("./client_integration_contracts.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    assert(contracts && typeof contracts === "object", "contracts export missing");

    assert(contracts.gameSession.endpoint === "/game/game-session", "gameSession endpoint mismatch");
    assert(contracts.multiplayerMatch.endpoint === "/game/multiplayer-match", "multiplayerMatch endpoint mismatch");
    assert(contracts.aiDifficultyCalibration.endpoint === "/game/ai-difficulty-calibration", "aiDifficultyCalibration endpoint mismatch");

    assert(contracts.gameSession.method === "POST", "gameSession method mismatch");
    assert(contracts.multiplayerMatch.method === "POST", "multiplayerMatch method mismatch");
    assert(contracts.aiDifficultyCalibration.method === "POST", "aiDifficultyCalibration method mismatch");

    console.log("OK PHASE16 CLIENT CONTRACT VERIFIER PASSED");
}

main();
