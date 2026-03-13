"use strict";

const adapter = require("./phase24_packaging_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const prod = adapter.main({
        buildId: "build-1101",
        version: "1.0.1",
        environment: "production",
        artifacts: [
            "backend/dist/server.js",
            "frontend/dist/index.html"
        ]
    });

    const stage = adapter.main({
        buildId: "build-1102",
        version: "1.0.2-rc1",
        environment: "staging",
        artifacts: [
            "backend/dist/server.js",
            "frontend/dist/index.html",
            "frontend/dist/assets/app.js",
            "frontend/dist/assets/app.css"
        ]
    });

    assert(prod.packageState === "assembled", "prod packageState mismatch");
    assert(stage.packageState === "assembled", "stage packageState mismatch");
    assert(prod.artifactCount === 2, "prod artifactCount mismatch");
    assert(stage.artifactCount === 4, "stage artifactCount mismatch");
    assert(prod.environment === "production", "prod environment mismatch");
    assert(stage.environment === "staging", "stage environment mismatch");

    console.log("OK PHASE24 PACKAGING RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
