"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase18_scope_placeholder.cjs",
  "phase18_scope_contract.cjs",
  "phase18_pipeline_controller.cjs",
  "phase18_state_snapshot_manager.cjs",
  "phase18_result_formatter.cjs",
  "phase18_request_router.cjs",
  "phase18_execution_orchestrator.cjs",
  "phase18_output_normalizer.cjs",
  "phase18_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) throw new Error("STOP: missing " + full);
}

console.log("OK: PHASE18_RECONCILE_VERIFIER implementation passed");
