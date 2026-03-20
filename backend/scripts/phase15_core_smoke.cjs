"use strict";

const { getPhase15Scope } = require("./phase15_scope_placeholder.cjs");
const { getPhase15ScopeContract } = require("./phase15_scope_contract.cjs");
const { createPhase15PipelineController } = require("./phase15_pipeline_controller.cjs");
const { createPhase15StateSnapshotManager } = require("./phase15_state_snapshot_manager.cjs");
const { formatPhase15Result } = require("./phase15_result_formatter.cjs");
const { routePhase15Request } = require("./phase15_request_router.cjs");
const { createPhase15ExecutionOrchestrator } = require("./phase15_execution_orchestrator.cjs");
const { normalizePhase15Output } = require("./phase15_output_normalizer.cjs");
const { createPhase15IntegrationAdapter } = require("./phase15_integration_adapter.cjs");
const { createPhase15RuntimeBridge } = require("./phase15_runtime_bridge.cjs");
const { runPhase15ValidationGateway } = require("./phase15_validation_gateway.cjs");

const scope = getPhase15Scope();
const contract = getPhase15ScopeContract();
const controller = createPhase15PipelineController();
const snapshotManager = createPhase15StateSnapshotManager();
const orchestrator = createPhase15ExecutionOrchestrator();
const adapter = createPhase15IntegrationAdapter();
const bridge = createPhase15RuntimeBridge();

if (!scope || scope.phase !== "phase15") {
  throw new Error("STOP: phase15 scope invalid");
}

if (!contract || contract.phase !== "phase15") {
  throw new Error("STOP: phase15 contract invalid");
}

const routed = routePhase15Request({ route: "integration", payload: { mode: "test" } });
if (!routed.ok) {
  throw new Error("STOP: phase15 request router failed");
}

const pipelineResult = controller.run({ mode: "integration-check", routed });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase15 pipeline controller failed");
}

const integrated = adapter.connect({ pipelineResult });
if (!integrated.ok) {
  throw new Error("STOP: phase15 integration adapter failed");
}

const bridged = bridge.bridge({ integrated });
if (!bridged.ok) {
  throw new Error("STOP: phase15 runtime bridge failed");
}

const executed = orchestrator.execute({ bridged });
if (!executed.ok) {
  throw new Error("STOP: phase15 execution orchestrator failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase15", status: "integration" });
if (!snapshot.ok) {
  throw new Error("STOP: phase15 snapshot manager failed");
}

const formatted = formatPhase15Result({ executed, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase15 result formatter failed");
}

const normalized = normalizePhase15Output(formatted);
if (!normalized.ok) {
  throw new Error("STOP: phase15 output normalizer failed");
}

const validated = runPhase15ValidationGateway(normalized);
if (!validated.ok) {
  throw new Error("STOP: phase15 validation gateway failed");
}

console.log("OK: PHASE15_CORE_SMOKE integration passed");
