"use strict";

const fs = require("fs");
const path = require("path");
const snapshot = require("./phase16_client_snapshot_export.cjs");

const outDir = path.join(__dirname, "..", "artifacts");
const outFile = path.join(outDir, "phase16_client_snapshot.json");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    fs.mkdirSync(outDir, { recursive: true });
    fs.writeFileSync(outFile, JSON.stringify(snapshot, null, 2) + "\n", "utf8");

    const loaded = JSON.parse(fs.readFileSync(outFile, "utf8"));

    assert(loaded.contracts.gameSession.endpoint === snapshot.contracts.gameSession.endpoint, "roundtrip gameSession endpoint mismatch");
    assert(loaded.contracts.multiplayerMatch.endpoint === snapshot.contracts.multiplayerMatch.endpoint, "roundtrip multiplayerMatch endpoint mismatch");
    assert(loaded.contracts.aiDifficultyCalibration.endpoint === snapshot.contracts.aiDifficultyCalibration.endpoint, "roundtrip ai endpoint mismatch");

    assert(loaded.payloadBundle.gameSession.payload.player === snapshot.payloadBundle.gameSession.payload.player, "roundtrip gameSession payload mismatch");
    assert(loaded.payloadBundle.multiplayerMatch.payload.matchId === snapshot.payloadBundle.multiplayerMatch.payload.matchId, "roundtrip multiplayerMatch payload mismatch");
    assert(loaded.payloadBundle.aiDifficultyCalibration.payload.playerAccuracy === snapshot.payloadBundle.aiDifficultyCalibration.payload.playerAccuracy, "roundtrip ai payload mismatch");

    console.log("OK PHASE16 SNAPSHOT ROUNDTRIP VERIFIER PASSED");
}

main();
