"use strict";

const { getPhase16Scope } = require("./phase16_scope_placeholder.cjs");
const { getPhase16ScopeContract } = require("./phase16_scope_contract.cjs");
const { createPhase16PipelineController } = require("./phase16_pipeline_controller.cjs");
const { createPhase16StateSnapshotManager } = require("./phase16_state_snapshot_manager.cjs");
const { formatPhase16Result } = require("./phase16_result_formatter.cjs");

const scope = getPhase16Scope();
const contract = getPhase16ScopeContract();
const controller = createPhase16PipelineController();
const snapshotManager = createPhase16StateSnapshotManager();

if (!scope || scope.phase !== "phase16") {
  throw new Error("STOP: phase16 scope invalid");
}

if (!contract || contract.phase !== "phase16") {
  throw new Error("STOP: phase16 contract invalid");
}

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase16 pipeline controller failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase16", status: "testing" });
if (!snapshot.ok) {
  throw new Error("STOP: phase16 snapshot manager failed");
}

const formatted = formatPhase16Result({ pipelineResult, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase16 result formatter failed");
}

console.log("OK: PHASE16_CORE_SMOKE foundation passed");
