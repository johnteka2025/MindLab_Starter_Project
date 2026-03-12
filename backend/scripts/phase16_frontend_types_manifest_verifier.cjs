"use strict";

const fs = require("fs");
const path = require("path");

const typesDir = path.join(__dirname, "..", "frontend-types");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const contractsFile = path.join(typesDir, "contracts.ts");
    const payloadsFile = path.join(typesDir, "payloads.ts");
    const responsesFile = path.join(typesDir, "responses.ts");

    assert(fs.existsSync(typesDir), "frontend-types directory missing");
    assert(fs.existsSync(contractsFile), "contracts.ts missing");
    assert(fs.existsSync(payloadsFile), "payloads.ts missing");
    assert(fs.existsSync(responsesFile), "responses.ts missing");

    const contractsText = fs.readFileSync(contractsFile, "utf8");
    const payloadsText = fs.readFileSync(payloadsFile, "utf8");
    const responsesText = fs.readFileSync(responsesFile, "utf8");

    assert(contractsText.includes("apiContracts"), "contracts.ts content mismatch");
    assert(payloadsText.includes("apiPayloadExamples"), "payloads.ts content mismatch");
    assert(responsesText.includes("GameSessionResponse"), "responses.ts game session type missing");
    assert(responsesText.includes("MultiplayerMatchResponse"), "responses.ts multiplayer type missing");
    assert(responsesText.includes("AiDifficultyCalibrationResponse"), "responses.ts ai type missing");

    console.log("OK PHASE16 FRONTEND TYPES MANIFEST VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
