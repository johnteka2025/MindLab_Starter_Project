"use strict";

const adapter = require("./phase24_packaging_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        buildId: "build-1100",
        version: "1.0.0",
        environment: "production",
        artifacts: [
            "backend/dist/server.js",
            "frontend/dist/index.html",
            "frontend/dist/assets/app.js"
        ]
    });

    assert(result.ok === true, "packaging ok mismatch");
    assert(result.packageId === "pkg-build-1100", "packageId mismatch");
    assert(result.buildId === "build-1100", "buildId mismatch");
    assert(result.version === "1.0.0", "version mismatch");
    assert(result.environment === "production", "environment mismatch");
    assert(result.artifactCount === 3, "artifactCount mismatch");
    assert(result.packageState === "assembled", "packageState mismatch");

    console.log("OK PHASE24 PACKAGING SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
