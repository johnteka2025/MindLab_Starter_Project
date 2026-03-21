"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase17_scope_placeholder.cjs",
  "phase17_scope_contract.cjs",
  "phase17_pipeline_controller.cjs",
  "phase17_state_snapshot_manager.cjs",
  "phase17_result_formatter.cjs",
  "phase17_request_router.cjs",
  "phase17_execution_orchestrator.cjs",
  "phase17_output_normalizer.cjs",
  "phase17_integration_adapter.cjs",
  "phase17_runtime_bridge.cjs",
  "phase17_validation_gateway.cjs",
  "phase17_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE17_RECONCILE_VERIFIER integration passed");
