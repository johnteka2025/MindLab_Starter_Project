"use strict";

const { getPhase18Scope } = require("./phase18_scope_placeholder.cjs");
const { getPhase18ScopeContract } = require("./phase18_scope_contract.cjs");
const { createPhase18PipelineController } = require("./phase18_pipeline_controller.cjs");
const { createPhase18StateSnapshotManager } = require("./phase18_state_snapshot_manager.cjs");
const { formatPhase18Result } = require("./phase18_result_formatter.cjs");
const { routePhase18Request } = require("./phase18_request_router.cjs");
const { createPhase18ExecutionOrchestrator } = require("./phase18_execution_orchestrator.cjs");
const { normalizePhase18Output } = require("./phase18_output_normalizer.cjs");

const scope = getPhase18Scope();
const contract = getPhase18ScopeContract();
const controller = createPhase18PipelineController();
const snapshotManager = createPhase18StateSnapshotManager();
const orchestrator = createPhase18ExecutionOrchestrator();

if (!scope || scope.phase !== "phase18") throw new Error("STOP: phase18 scope invalid");
if (!contract || contract.phase !== "phase18") throw new Error("STOP: phase18 contract invalid");

const routed = routePhase18Request({ route: "implementation", payload: { mode: "test" } });
if (!routed.ok) throw new Error("STOP: phase18 request router failed");

const pipelineResult = controller.run({ mode: "implementation-check", routed });
if (!pipelineResult.ok) throw new Error("STOP: phase18 pipeline controller failed");

const executed = orchestrator.execute({ pipelineResult });
if (!executed.ok) throw new Error("STOP: phase18 execution orchestrator failed");

const snapshot = snapshotManager.takeSnapshot({ phase: "phase18", status: "implementation" });
if (!snapshot.ok) throw new Error("STOP: phase18 snapshot manager failed");

const formatted = formatPhase18Result({ executed, snapshot });
if (!formatted.ok) throw new Error("STOP: phase18 result formatter failed");

const normalized = normalizePhase18Output(formatted);
if (!normalized.ok) throw new Error("STOP: phase18 output normalizer failed");

console.log("OK: PHASE18_CORE_SMOKE implementation passed");
