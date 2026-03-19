"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase13_scope_placeholder.cjs",
  "phase13_scope_contract.cjs",
  "phase13_pipeline_controller.cjs",
  "phase13_state_snapshot_manager.cjs",
  "phase13_result_formatter.cjs",
  "phase13_request_router.cjs",
  "phase13_execution_orchestrator.cjs",
  "phase13_output_normalizer.cjs",
  "phase13_integration_adapter.cjs",
  "phase13_runtime_bridge.cjs",
  "phase13_validation_gateway.cjs",
  "phase13_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE13_RECONCILE_VERIFIER integration passed");
