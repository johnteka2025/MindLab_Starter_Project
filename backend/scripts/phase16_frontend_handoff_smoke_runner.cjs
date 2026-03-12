"use strict";

const writer = require("./phase16_frontend_handoff_package_writer.cjs");
const verifier = require("./phase16_frontend_handoff_package_verifier.cjs");
const cleanup = require("./phase16_frontend_handoff_cleanup_guard.cjs");

function runStep(name, fn) {
    try {
        fn();
        console.log("OK " + name + " PASSED");
    } catch (error) {
        console.error("STOP " + name + " FAILED");
        throw error;
    }
}

function main() {
    runStep("HANDOFF WRITER", writer.main);
    runStep("HANDOFF VERIFIER", verifier.main);
    runStep("HANDOFF CLEANUP", cleanup.main);

    console.log("OK PHASE16 HANDOFF SMOKE RUNNER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
