"use strict";
const { getPhase15Scope } = require("./phase15_scope_placeholder.cjs");
const { getPhase15ScopeContract } = require("./phase15_scope_contract.cjs");
const { createPhase15PipelineController } = require("./phase15_pipeline_controller.cjs");
const { createPhase15StateSnapshotManager } = require("./phase15_state_snapshot_manager.cjs");
const { formatPhase15Result } = require("./phase15_result_formatter.cjs");
const { routePhase15Request } = require("./phase15_request_router.cjs");
const { createPhase15ExecutionOrchestrator } = require("./phase15_execution_orchestrator.cjs");
const { normalizePhase15Output } = require("./phase15_output_normalizer.cjs");

const scope = getPhase15Scope();
if (!scope || scope.phase !== "phase15") throw new Error("STOP");

const routed = routePhase15Request({mode:"impl"});
const controller = createPhase15PipelineController();
const result = controller.run(routed);

const orchestrator = createPhase15ExecutionOrchestrator();
const executed = orchestrator.execute(result);

const snapshot = createPhase15StateSnapshotManager().takeSnapshot(executed);
const formatted = formatPhase15Result(snapshot);
const normalized = normalizePhase15Output(formatted);

if (!normalized.ok) throw new Error("STOP");

console.log("OK: PHASE15 IMPLEMENTATION SMOKE");
