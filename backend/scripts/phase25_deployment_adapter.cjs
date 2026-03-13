"use strict";

function assertString(value, fieldName) {
    if (typeof value !== "string" || value.trim() === "") {
        throw new Error(fieldName + " must be a non-empty string");
    }
}

function assertArray(value, fieldName) {
    if (!Array.isArray(value)) {
        throw new Error(fieldName + " must be an array");
    }
}

function main(input) {
    const payload = input || {
        deploymentId: "deploy-1200",
        buildId: "build-1100",
        environment: "production",
        targets: [
            "backend-service",
            "frontend-static-site"
        ]
    };

    assertString(payload.deploymentId, "deploymentId");
    assertString(payload.buildId, "buildId");
    assertString(payload.environment, "environment");
    assertArray(payload.targets, "targets");

    const result = {
        ok: true,
        deploymentRunId: "run-" + payload.deploymentId,
        deploymentId: payload.deploymentId,
        buildId: payload.buildId,
        environment: payload.environment,
        targetCount: payload.targets.length,
        targets: payload.targets.slice(),
        deploymentState: "ready",
        preparedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
