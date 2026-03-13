"use strict";

const adapter = require("./phase26_final_release_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const stable = adapter.main({
        releaseId: "release-1301",
        deploymentId: "deploy-1201",
        version: "1.0.1",
        releaseNotes: [
            "Deployment validated",
            "Release tagged"
        ]
    });

    const hotfix = adapter.main({
        releaseId: "release-1302",
        deploymentId: "deploy-1202",
        version: "1.0.2-hotfix",
        releaseNotes: [
            "Hotfix deployment validated",
            "Production checks passed"
        ]
    });

    assert(stable.releaseState === "ready_for_signoff", "stable releaseState mismatch");
    assert(hotfix.releaseState === "ready_for_signoff", "hotfix releaseState mismatch");
    assert(stable.version === "1.0.1", "stable version mismatch");
    assert(hotfix.version === "1.0.2-hotfix", "hotfix version mismatch");

    console.log("OK PHASE26 FINAL RELEASE RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
