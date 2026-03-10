"use strict";

const path = require("path");
const contracts = require("./client_integration_contracts.cjs");

const manifest = {
    generatedAt: new Date().toISOString(),
    artifacts: {
        snapshotJson: path.join(__dirname, "..", "artifacts", "phase16_client_snapshot.json")
    },
    endpoints: contracts,
    frontendFiles: [
        "game-session-client.ts",
        "multiplayer-match-client.ts",
        "ai-difficulty-client.ts"
    ]
};

module.exports = manifest;

if (require.main === module) {
    console.log(JSON.stringify(manifest, null, 2));
}
