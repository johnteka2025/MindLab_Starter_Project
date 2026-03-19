"use strict";

const { getPhase14Scope } = require("./phase14_scope_placeholder.cjs");
const { getPhase14ScopeContract } = require("./phase14_scope_contract.cjs");
const { createPhase14PipelineController } = require("./phase14_pipeline_controller.cjs");
const { createPhase14StateSnapshotManager } = require("./phase14_state_snapshot_manager.cjs");
const { formatPhase14Result } = require("./phase14_result_formatter.cjs");

const scope = getPhase14Scope();
const contract = getPhase14ScopeContract();
const controller = createPhase14PipelineController();
const snapshotManager = createPhase14StateSnapshotManager();

if (!scope || scope.phase !== "phase14") {
  throw new Error("STOP: phase14 scope invalid");
}

if (!contract || contract.phase !== "phase14") {
  throw new Error("STOP: phase14 contract invalid");
}

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase14 pipeline controller failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase14", status: "testing" });
if (!snapshot.ok) {
  throw new Error("STOP: phase14 snapshot manager failed");
}

const formatted = formatPhase14Result({ pipelineResult, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase14 result formatter failed");
}

console.log("OK: PHASE14_CORE_SMOKE foundation passed");
