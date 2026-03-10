"use strict";

const snapshot = require("./phase16_client_snapshot_export.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    assert(snapshot.contracts.gameSession.endpoint === "/game/game-session", "snapshot gameSession endpoint mismatch");
    assert(snapshot.contracts.multiplayerMatch.endpoint === "/game/multiplayer-match", "snapshot multiplayerMatch endpoint mismatch");
    assert(snapshot.contracts.aiDifficultyCalibration.endpoint === "/game/ai-difficulty-calibration", "snapshot aiDifficultyCalibration endpoint mismatch");

    assert(snapshot.payloadBundle.gameSession.payload.player === "Maya", "snapshot gameSession payload mismatch");
    assert(snapshot.payloadBundle.multiplayerMatch.payload.matchId === "match-200", "snapshot multiplayerMatch payload mismatch");
    assert(snapshot.payloadBundle.aiDifficultyCalibration.payload.playerAccuracy === 90, "snapshot aiDifficulty payload mismatch");

    console.log("OK PHASE16 CLIENT SNAPSHOT VERIFIER PASSED");
}

main();
