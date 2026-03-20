"use strict";

const { getPhase14Scope } = require("./phase14_scope_placeholder.cjs");
const { getPhase14ScopeContract } = require("./phase14_scope_contract.cjs");
const { createPhase14PipelineController } = require("./phase14_pipeline_controller.cjs");
const { createPhase14StateSnapshotManager } = require("./phase14_state_snapshot_manager.cjs");
const { formatPhase14Result } = require("./phase14_result_formatter.cjs");
const { routePhase14Request } = require("./phase14_request_router.cjs");
const { createPhase14ExecutionOrchestrator } = require("./phase14_execution_orchestrator.cjs");
const { normalizePhase14Output } = require("./phase14_output_normalizer.cjs");
const { createPhase14IntegrationAdapter } = require("./phase14_integration_adapter.cjs");
const { createPhase14RuntimeBridge } = require("./phase14_runtime_bridge.cjs");
const { runPhase14ValidationGateway } = require("./phase14_validation_gateway.cjs");

const scope = getPhase14Scope();
const contract = getPhase14ScopeContract();
const controller = createPhase14PipelineController();
const snapshotManager = createPhase14StateSnapshotManager();
const orchestrator = createPhase14ExecutionOrchestrator();
const adapter = createPhase14IntegrationAdapter();
const bridge = createPhase14RuntimeBridge();

if (!scope || scope.phase !== "phase14") {
  throw new Error("STOP: phase14 scope invalid");
}

if (!contract || contract.phase !== "phase14") {
  throw new Error("STOP: phase14 contract invalid");
}

const routed = routePhase14Request({ route: "integration", payload: { mode: "test" } });
if (!routed.ok) {
  throw new Error("STOP: phase14 request router failed");
}

const pipelineResult = controller.run({ mode: "integration-check", routed });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase14 pipeline controller failed");
}

const integrated = adapter.connect({ pipelineResult });
if (!integrated.ok) {
  throw new Error("STOP: phase14 integration adapter failed");
}

const bridged = bridge.bridge({ integrated });
if (!bridged.ok) {
  throw new Error("STOP: phase14 runtime bridge failed");
}

const executed = orchestrator.execute({ bridged });
if (!executed.ok) {
  throw new Error("STOP: phase14 execution orchestrator failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase14", status: "integration" });
if (!snapshot.ok) {
  throw new Error("STOP: phase14 snapshot manager failed");
}

const formatted = formatPhase14Result({ executed, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase14 result formatter failed");
}

const normalized = normalizePhase14Output(formatted);
if (!normalized.ok) {
  throw new Error("STOP: phase14 output normalizer failed");
}

const validated = runPhase14ValidationGateway(normalized);
if (!validated.ok) {
  throw new Error("STOP: phase14 validation gateway failed");
}

console.log("OK: PHASE14_CORE_SMOKE integration passed");
