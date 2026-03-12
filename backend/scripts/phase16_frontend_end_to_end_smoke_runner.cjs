"use strict";

const writer = require("./phase16_ts_file_writer.cjs");
const typesVerifier = require("./phase16_frontend_types_manifest_verifier.cjs");
const handoffWriter = require("./phase16_frontend_handoff_package_writer.cjs");
const handoffVerifier = require("./phase16_frontend_handoff_package_verifier.cjs");
const cleanupGuard = require("./phase16_frontend_handoff_cleanup_guard.cjs");

function runStep(name, fn) {
    fn();
    console.log("OK " + name + " PASSED");
}

function main() {
    runStep("TS FILE WRITER", writer.main);
    runStep("TYPES MANIFEST VERIFIER", typesVerifier.main);
    runStep("HANDOFF WRITER", handoffWriter.main);
    runStep("HANDOFF VERIFIER", handoffVerifier.main);
    runStep("HANDOFF CLEANUP", cleanupGuard.main);

    console.log("OK PHASE16 FRONTEND END TO END SMOKE RUNNER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
