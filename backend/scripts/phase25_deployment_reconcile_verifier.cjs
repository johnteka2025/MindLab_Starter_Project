"use strict";

const adapter = require("./phase25_deployment_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const prod = adapter.main({
        deploymentId: "deploy-1201",
        buildId: "build-1101",
        environment: "production",
        targets: [
            "backend-service",
            "frontend-static-site"
        ]
    });

    const stage = adapter.main({
        deploymentId: "deploy-1202",
        buildId: "build-1102",
        environment: "staging",
        targets: [
            "backend-service",
            "frontend-static-site",
            "asset-cdn"
        ]
    });

    assert(prod.deploymentState === "ready", "prod deploymentState mismatch");
    assert(stage.deploymentState === "ready", "stage deploymentState mismatch");
    assert(prod.targetCount === 2, "prod targetCount mismatch");
    assert(stage.targetCount === 3, "stage targetCount mismatch");
    assert(prod.environment === "production", "prod environment mismatch");
    assert(stage.environment === "staging", "stage environment mismatch");

    console.log("OK PHASE25 DEPLOYMENT RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
