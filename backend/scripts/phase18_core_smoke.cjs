"use strict";

const { getPhase18Scope } = require("./phase18_scope_placeholder.cjs");
const { getPhase18ScopeContract } = require("./phase18_scope_contract.cjs");
const { createPhase18PipelineController } = require("./phase18_pipeline_controller.cjs");
const { createPhase18StateSnapshotManager } = require("./phase18_state_snapshot_manager.cjs");
const { formatPhase18Result } = require("./phase18_result_formatter.cjs");

const scope = getPhase18Scope();
const contract = getPhase18ScopeContract();
const controller = createPhase18PipelineController();
const snapshotManager = createPhase18StateSnapshotManager();

if (!scope || scope.phase !== "phase18") throw new Error("STOP: phase18 scope invalid");
if (!contract || contract.phase !== "phase18") throw new Error("STOP: phase18 contract invalid");

const pipelineResult = controller.run({ mode: "foundation-check" });
if (!pipelineResult.ok) throw new Error("STOP: phase18 pipeline controller failed");

const snapshot = snapshotManager.takeSnapshot({ phase: "phase18", status: "testing" });
if (!snapshot.ok) throw new Error("STOP: phase18 snapshot manager failed");

const formatted = formatPhase18Result({ pipelineResult, snapshot });
if (!formatted.ok) throw new Error("STOP: phase18 result formatter failed");

console.log("OK: PHASE18_CORE_SMOKE foundation passed");
