"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase16_scope_placeholder.cjs",
  "phase16_scope_contract.cjs",
  "phase16_pipeline_controller.cjs",
  "phase16_state_snapshot_manager.cjs",
  "phase16_result_formatter.cjs",
  "phase16_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE16_RECONCILE_VERIFIER foundation passed");
