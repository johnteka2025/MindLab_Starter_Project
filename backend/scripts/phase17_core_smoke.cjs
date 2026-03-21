"use strict";

const { getPhase17Scope } = require("./phase17_scope_placeholder.cjs");
const { getPhase17ScopeContract } = require("./phase17_scope_contract.cjs");
const { createPhase17PipelineController } = require("./phase17_pipeline_controller.cjs");
const { createPhase17StateSnapshotManager } = require("./phase17_state_snapshot_manager.cjs");
const { formatPhase17Result } = require("./phase17_result_formatter.cjs");

const scope = getPhase17Scope();
const contract = getPhase17ScopeContract();
const controller = createPhase17PipelineController();
const snapshotManager = createPhase17StateSnapshotManager();

if (!scope || scope.phase !== "phase17") {
  throw new Error("STOP: phase17 scope invalid");
}

if (!contract || contract.phase !== "phase17") {
  throw new Error("STOP: phase17 contract invalid");
}

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase17 pipeline controller failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase17", status: "testing" });
if (!snapshot.ok) {
  throw new Error("STOP: phase17 snapshot manager failed");
}

const formatted = formatPhase17Result({ pipelineResult, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase17 result formatter failed");
}

console.log("OK: PHASE17_CORE_SMOKE foundation passed");
