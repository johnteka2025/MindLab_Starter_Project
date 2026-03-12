"use strict";

const writer = require("./phase16_ts_file_writer.cjs");
const typesVerifier = require("./phase16_frontend_types_manifest_verifier.cjs");
const handoffSmoke = require("./phase16_frontend_handoff_smoke_runner.cjs");

function runStep(name, fn) {
    fn();
    console.log("OK " + name + " PASSED");
}

function main() {
    runStep("TS FILE WRITER", writer.main);
    runStep("TYPES MANIFEST VERIFIER", typesVerifier.main);
    runStep("HANDOFF SMOKE", handoffSmoke.main);

    console.log("OK PHASE16 FRONTEND END TO END SMOKE RUNNER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
