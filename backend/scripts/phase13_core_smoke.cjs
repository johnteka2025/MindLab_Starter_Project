"use strict";

const { getPhase13Scope } = require("./phase13_scope_placeholder.cjs");
const { getPhase13ScopeContract } = require("./phase13_scope_contract.cjs");
const { createPhase13PipelineController } = require("./phase13_pipeline_controller.cjs");
const { createPhase13StateSnapshotManager } = require("./phase13_state_snapshot_manager.cjs");
const { formatPhase13Result } = require("./phase13_result_formatter.cjs");
const { routePhase13Request } = require("./phase13_request_router.cjs");
const { createPhase13ExecutionOrchestrator } = require("./phase13_execution_orchestrator.cjs");
const { normalizePhase13Output } = require("./phase13_output_normalizer.cjs");
const { createPhase13IntegrationAdapter } = require("./phase13_integration_adapter.cjs");
const { createPhase13RuntimeBridge } = require("./phase13_runtime_bridge.cjs");
const { runPhase13ValidationGateway } = require("./phase13_validation_gateway.cjs");

const scope = getPhase13Scope();
const contract = getPhase13ScopeContract();
const controller = createPhase13PipelineController();
const snapshotManager = createPhase13StateSnapshotManager();
const orchestrator = createPhase13ExecutionOrchestrator();
const adapter = createPhase13IntegrationAdapter();
const bridge = createPhase13RuntimeBridge();

if (!scope || scope.phase !== "phase13") {
  throw new Error("STOP: phase13 scope invalid");
}

if (!contract || contract.phase !== "phase13") {
  throw new Error("STOP: phase13 contract invalid");
}

const routed = routePhase13Request({ route: "integration", payload: { mode: "test" } });
if (!routed.ok) {
  throw new Error("STOP: phase13 request router failed");
}

const pipelineResult = controller.run({ mode: "integration-check", routed });
if (!pipelineResult.ok) {
  throw new Error("STOP: phase13 pipeline controller failed");
}

const integrated = adapter.connect({ pipelineResult });
if (!integrated.ok) {
  throw new Error("STOP: phase13 integration adapter failed");
}

const bridged = bridge.bridge({ integrated });
if (!bridged.ok) {
  throw new Error("STOP: phase13 runtime bridge failed");
}

const executed = orchestrator.execute({ bridged });
if (!executed.ok) {
  throw new Error("STOP: phase13 execution orchestrator failed");
}

const snapshot = snapshotManager.takeSnapshot({ phase: "phase13", status: "integration" });
if (!snapshot.ok) {
  throw new Error("STOP: phase13 snapshot manager failed");
}

const formatted = formatPhase13Result({ executed, snapshot });
if (!formatted.ok) {
  throw new Error("STOP: phase13 result formatter failed");
}

const normalized = normalizePhase13Output(formatted);
if (!normalized.ok) {
  throw new Error("STOP: phase13 output normalizer failed");
}

const validated = runPhase13ValidationGateway(normalized);
if (!validated.ok) {
  throw new Error("STOP: phase13 validation gateway failed");
}

console.log("OK: PHASE13_CORE_SMOKE integration passed");
