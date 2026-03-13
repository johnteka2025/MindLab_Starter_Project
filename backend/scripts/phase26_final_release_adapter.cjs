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
        releaseId: "release-1300",
        deploymentId: "deploy-1200",
        version: "1.0.0",
        releaseNotes: [
            "Phase25 deployment completed",
            "Production package validated"
        ]
    };

    assertString(payload.releaseId, "releaseId");
    assertString(payload.deploymentId, "deploymentId");
    assertString(payload.version, "version");
    assertArray(payload.releaseNotes, "releaseNotes");

    const result = {
        ok: true,
        finalReleaseId: "final-" + payload.releaseId,
        releaseId: payload.releaseId,
        deploymentId: payload.deploymentId,
        version: payload.version,
        releaseNotes: payload.releaseNotes.slice(),
        releaseState: "ready_for_signoff",
        finalizedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
