"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase14_scope_placeholder.cjs",
  "phase14_scope_contract.cjs",
  "phase14_pipeline_controller.cjs",
  "phase14_state_snapshot_manager.cjs",
  "phase14_result_formatter.cjs",
  "phase14_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE14_RECONCILE_VERIFIER foundation passed");
