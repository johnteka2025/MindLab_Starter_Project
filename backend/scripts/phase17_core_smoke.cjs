"use strict";

const { getPhase17Scope } = require("./phase17_scope_placeholder.cjs");
const { getPhase17ScopeContract } = require("./phase17_scope_contract.cjs");
const { createPhase17PipelineController } = require("./phase17_pipeline_controller.cjs");
const { createPhase17StateSnapshotManager } = require("./phase17_state_snapshot_manager.cjs");
const { formatPhase17Result } = require("./phase17_result_formatter.cjs");
const { routePhase17Request } = require("./phase17_request_router.cjs");
const { createPhase17ExecutionOrchestrator } = require("./phase17_execution_orchestrator.cjs");
const { normalizePhase17Output } = require("./phase17_output_normalizer.cjs");
const { createPhase17IntegrationAdapter } = require("./phase17_integration_adapter.cjs");
const { createPhase17RuntimeBridge } = require("./phase17_runtime_bridge.cjs");
const { runPhase17ValidationGateway } = require("./phase17_validation_gateway.cjs");

const scope = getPhase17Scope();
const contract = getPhase17ScopeContract();
const controller = createPhase17PipelineController();
const snapshotManager = createPhase17StateSnapshotManager();
const orchestrator = createPhase17ExecutionOrchestrator();
const adapter = createPhase17IntegrationAdapter();
const bridge = createPhase17RuntimeBridge();

if (!scope || scope.phase !== "phase17") {
  throw new Error("STOP: phase17 scope invalid");
}

if (!contract || contract.phase !== "phase17") {
  throw new Error("STOP: phase17 contract invalid");
}

const routed = routePhase17Request({ route: "integration", payload: { mode: "test" } });
if (!routed.ok) {
  throw new Error("STOP: phase17 request router failed");
}

const pipelineResult = controller.run({ mode: "integration-check", routed });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase17 pipeline controller failed");
}

const integrated = adapter.connect({ pipelineResult });
if (!integrated.ok) {
  throw new Error("STOP: phase17 integration adapter failed");
}

const bridged = bridge.bridge({ integrated });
if (!bridged.ok) {
  throw new Error("STOP: phase17 runtime bridge failed");
}

const executed = orchestrator.execute({ bridged });
if (!executed.ok) {
  throw new Error("STOP: phase17 execution orchestrator failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase17", status: "integration" });
if (!snapshot.ok) {
  throw new Error("STOP: phase17 snapshot manager failed");
}

const formatted = formatPhase17Result({ executed, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase17 result formatter failed");
}

const normalized = normalizePhase17Output(formatted);
if (!normalized.ok) {
  throw new Error("STOP: phase17 output normalizer failed");
}

const validated = runPhase17ValidationGateway(normalized);
if (!validated.ok) {
  throw new Error("STOP: phase17 validation gateway failed");
}

console.log("OK: PHASE17_CORE_SMOKE integration passed");
