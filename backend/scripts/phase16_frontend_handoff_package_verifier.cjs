"use strict";

const fs = require("fs");
const path = require("path");

const outDir = path.join(__dirname, "..", "artifacts", "frontend-handoff");
const manifestFile = path.join(outDir, "manifest.json");
const snapshotFile = path.join(outDir, "snapshot.json");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    assert(fs.existsSync(outDir), "frontend-handoff directory missing");
    assert(fs.existsSync(manifestFile), "manifest.json missing");
    assert(fs.existsSync(snapshotFile), "snapshot.json missing");

    const manifest = JSON.parse(fs.readFileSync(manifestFile, "utf8"));
    const snapshot = JSON.parse(fs.readFileSync(snapshotFile, "utf8"));

    assert(manifest.endpoints.gameSession.endpoint === "/game/game-session", "manifest gameSession endpoint mismatch");
    assert(manifest.endpoints.multiplayerMatch.endpoint === "/game/multiplayer-match", "manifest multiplayerMatch endpoint mismatch");
    assert(manifest.endpoints.aiDifficultyCalibration.endpoint === "/game/ai-difficulty-calibration", "manifest ai endpoint mismatch");

    assert(snapshot.contracts.gameSession.endpoint === "/game/game-session", "snapshot gameSession endpoint mismatch");
    assert(snapshot.payloadBundle.multiplayerMatch.payload.matchId === "match-200", "snapshot multiplayerMatch payload mismatch");
    assert(snapshot.payloadBundle.aiDifficultyCalibration.payload.playerAccuracy === 90, "snapshot ai payload mismatch");

    console.log("OK PHASE16 FRONTEND HANDOFF PACKAGE VERIFIER PASSED");
}

main();
