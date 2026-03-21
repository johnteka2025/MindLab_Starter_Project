"use strict";

const { getPhase16Scope } = require("./phase16_scope_placeholder.cjs");
const { getPhase16ScopeContract } = require("./phase16_scope_contract.cjs");
const { createPhase16PipelineController } = require("./phase16_pipeline_controller.cjs");
const { createPhase16StateSnapshotManager } = require("./phase16_state_snapshot_manager.cjs");
const { formatPhase16Result } = require("./phase16_result_formatter.cjs");
const { routePhase16Request } = require("./phase16_request_router.cjs");
const { createPhase16ExecutionOrchestrator } = require("./phase16_execution_orchestrator.cjs");
const { normalizePhase16Output } = require("./phase16_output_normalizer.cjs");
const { createPhase16IntegrationAdapter } = require("./phase16_integration_adapter.cjs");
const { createPhase16RuntimeBridge } = require("./phase16_runtime_bridge.cjs");
const { runPhase16ValidationGateway } = require("./phase16_validation_gateway.cjs");

const scope = getPhase16Scope();
const contract = getPhase16ScopeContract();
const controller = createPhase16PipelineController();
const snapshotManager = createPhase16StateSnapshotManager();
const orchestrator = createPhase16ExecutionOrchestrator();
const adapter = createPhase16IntegrationAdapter();
const bridge = createPhase16RuntimeBridge();

if (!scope || scope.phase !== "phase16") {
  throw new Error("STOP: phase16 scope invalid");
}

if (!contract || contract.phase !== "phase16") {
  throw new Error("STOP: phase16 contract invalid");
}

const routed = routePhase16Request({ route: "integration", payload: { mode: "test" } });
if (!routed.ok) {
  throw new Error("STOP: phase16 request router failed");
}

const pipelineResult = controller.run({ mode: "integration-check", routed });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase16 pipeline controller failed");
}

const integrated = adapter.connect({ pipelineResult });
if (!integrated.ok) {
  throw new Error("STOP: phase16 integration adapter failed");
}

const bridged = bridge.bridge({ integrated });
if (!bridged.ok) {
  throw new Error("STOP: phase16 runtime bridge failed");
}

const executed = orchestrator.execute({ bridged });
if (!executed.ok) {
  throw new Error("STOP: phase16 execution orchestrator failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase16", status: "integration" });
if (!snapshot.ok) {
  throw new Error("STOP: phase16 snapshot manager failed");
}

const formatted = formatPhase16Result({ executed, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase16 result formatter failed");
}

const normalized = normalizePhase16Output(formatted);
if (!normalized.ok) {
  throw new Error("STOP: phase16 output normalizer failed");
}

const validated = runPhase16ValidationGateway(normalized);
if (!validated.ok) {
  throw new Error("STOP: phase16 validation gateway failed");
}

console.log("OK: PHASE16_CORE_SMOKE integration passed");
