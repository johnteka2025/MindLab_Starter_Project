"use strict";
const fs=require("fs");const path=require("path");
const required=[
"phase15_scope_placeholder.cjs",
"phase15_scope_contract.cjs",
"phase15_pipeline_controller.cjs",
"phase15_state_snapshot_manager.cjs",
"phase15_result_formatter.cjs",
"phase15_request_router.cjs",
"phase15_execution_orchestrator.cjs",
"phase15_output_normalizer.cjs",
"phase15_core_smoke.cjs"
];
for(const f of required){
 const full=path.join(__dirname,f);
 if(!fs.existsSync(full)) throw new Error("STOP: "+full);
}
console.log("OK: PHASE15 RECONCILE");
