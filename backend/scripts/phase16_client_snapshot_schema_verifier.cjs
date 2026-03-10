"use strict";

const snapshot = require("./phase16_client_snapshot_export.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function isNonEmptyString(value) {
    return typeof value === "string" && value.trim().length > 0;
}

function main() {
    assert(isNonEmptyString(snapshot.generatedAt), "generatedAt missing");

    assert(snapshot.contracts && typeof snapshot.contracts === "object", "contracts missing");
    assert(snapshot.payloadBundle && typeof snapshot.payloadBundle === "object", "payloadBundle missing");

    for (const key of ["gameSession", "multiplayerMatch", "aiDifficultyCalibration"]) {
        assert(snapshot.contracts[key], key + " contract missing");
        assert(snapshot.payloadBundle[key], key + " payload bundle missing");

        assert(isNonEmptyString(snapshot.contracts[key].endpoint), key + " contract endpoint missing");
        assert(snapshot.contracts[key].method === "POST", key + " contract method mismatch");

        assert(isNonEmptyString(snapshot.payloadBundle[key].endpoint), key + " payload endpoint missing");
        assert(snapshot.payloadBundle[key].method === "POST", key + " payload method mismatch");
        assert(snapshot.payloadBundle[key].payload && typeof snapshot.payloadBundle[key].payload === "object", key + " payload object missing");
    }

    console.log("OK PHASE16 CLIENT SNAPSHOT SCHEMA VERIFIER PASSED");
}

main();
