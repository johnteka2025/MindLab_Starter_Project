"use strict";

const adapter = require("./phase25_deployment_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        deploymentId: "deploy-1200",
        buildId: "build-1100",
        environment: "production",
        targets: [
            "backend-service",
            "frontend-static-site"
        ]
    });

    assert(result.ok === true, "deployment ok mismatch");
    assert(result.deploymentRunId === "run-deploy-1200", "deploymentRunId mismatch");
    assert(result.deploymentId === "deploy-1200", "deploymentId mismatch");
    assert(result.buildId === "build-1100", "buildId mismatch");
    assert(result.environment === "production", "environment mismatch");
    assert(result.targetCount === 2, "targetCount mismatch");
    assert(result.deploymentState === "ready", "deploymentState mismatch");

    console.log("OK PHASE25 DEPLOYMENT SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
