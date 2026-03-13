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
        buildId: "build-1100",
        version: "1.0.0",
        environment: "production",
        artifacts: [
            "backend/dist/server.js",
            "frontend/dist/index.html",
            "frontend/dist/assets/app.js"
        ]
    };

    assertString(payload.buildId, "buildId");
    assertString(payload.version, "version");
    assertString(payload.environment, "environment");
    assertArray(payload.artifacts, "artifacts");

    const result = {
        ok: true,
        packageId: "pkg-" + payload.buildId,
        buildId: payload.buildId,
        version: payload.version,
        environment: payload.environment,
        artifactCount: payload.artifacts.length,
        artifacts: payload.artifacts.slice(),
        packageState: "assembled",
        packagedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
