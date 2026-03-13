"use strict";

const adapter = require("./phase26_final_release_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        releaseId: "release-1300",
        deploymentId: "deploy-1200",
        version: "1.0.0",
        releaseNotes: [
            "Phase25 deployment completed",
            "Production package validated"
        ]
    });

    assert(result.ok === true, "release ok mismatch");
    assert(result.finalReleaseId === "final-release-1300", "finalReleaseId mismatch");
    assert(result.releaseId === "release-1300", "releaseId mismatch");
    assert(result.deploymentId === "deploy-1200", "deploymentId mismatch");
    assert(result.version === "1.0.0", "version mismatch");
    assert(result.releaseState === "ready_for_signoff", "releaseState mismatch");

    console.log("OK PHASE26 FINAL RELEASE SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
