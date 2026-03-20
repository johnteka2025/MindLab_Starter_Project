"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase15_scope_placeholder.cjs",
  "phase15_scope_contract.cjs",
  "phase15_pipeline_controller.cjs",
  "phase15_state_snapshot_manager.cjs",
  "phase15_result_formatter.cjs",
  "phase15_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE15_RECONCILE_VERIFIER foundation passed");
