"use strict";

const { getPhase13Scope } = require("./phase13_scope_placeholder.cjs");
const { getPhase13ScopeContract } = require("./phase13_scope_contract.cjs");
const { createPhase13PipelineController } = require("./phase13_pipeline_controller.cjs");
const { createPhase13StateSnapshotManager } = require("./phase13_state_snapshot_manager.cjs");
const { formatPhase13Result } = require("./phase13_result_formatter.cjs");

const scope = getPhase13Scope();
const contract = getPhase13ScopeContract();
const controller = createPhase13PipelineController();
const snapshotManager = createPhase13StateSnapshotManager();

if (!scope || scope.phase !== "phase13") {
  throw new Error("STOP: phase13 scope invalid");
}

if (!contract || contract.phase !== "phase13") {
  throw new Error("STOP: phase13 contract invalid");
}

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase13 pipeline controller failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase13", status: "testing" });
if (!snapshot.ok) {
  throw new Error("STOP: phase13 snapshot manager failed");
}

const formatted = formatPhase13Result({ pipelineResult, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase13 result formatter failed");
}

console.log("OK: PHASE13_CORE_SMOKE foundation passed");
