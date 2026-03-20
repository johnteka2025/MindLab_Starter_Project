"use strict";

const { getPhase15Scope } = require("./phase15_scope_placeholder.cjs");
const { getPhase15ScopeContract } = require("./phase15_scope_contract.cjs");
const { createPhase15PipelineController } = require("./phase15_pipeline_controller.cjs");
const { createPhase15StateSnapshotManager } = require("./phase15_state_snapshot_manager.cjs");
const { formatPhase15Result } = require("./phase15_result_formatter.cjs");

const scope = getPhase15Scope();
const contract = getPhase15ScopeContract();
const controller = createPhase15PipelineController();
const snapshotManager = createPhase15StateSnapshotManager();

if (!scope || scope.phase !== "phase15") {
  throw new Error("STOP: phase15 scope invalid");
}

if (!contract || contract.phase !== "phase15") {
  throw new Error("STOP: phase15 contract invalid");
}

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase15 pipeline controller failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase15", status: "testing" });
if (!snapshot.ok) {
  throw new Error("STOP: phase15 snapshot manager failed");
}

const formatted = formatPhase15Result({ pipelineResult, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase15 result formatter failed");
}

console.log("OK: PHASE15_CORE_SMOKE foundation passed");
