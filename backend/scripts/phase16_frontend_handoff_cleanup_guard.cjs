"use strict";

const fs = require("fs");
const path = require("path");

const artifactsDir = path.join(__dirname, "..", "artifacts");
const handoffDir = path.join(artifactsDir, "frontend-handoff");

function main() {
    if (fs.existsSync(handoffDir)) {
        fs.rmSync(handoffDir, { recursive: true, force: true });
        console.log("OK PHASE16 FRONTEND HANDOFF CLEANUP GUARD REMOVED HANDOFF DIR");
    } else {
        console.log("OK PHASE16 FRONTEND HANDOFF CLEANUP GUARD NO HANDOFF DIR");
    }

    if (fs.existsSync(artifactsDir)) {
        const remaining = fs.readdirSync(artifactsDir);
        if (remaining.length === 0) {
            fs.rmdirSync(artifactsDir);
            console.log("OK PHASE16 FRONTEND HANDOFF CLEANUP GUARD REMOVED ARTIFACTS DIR");
        } else {
            console.log("OK PHASE16 FRONTEND HANDOFF CLEANUP GUARD ARTIFACTS DIR NOT EMPTY");
        }
    } else {
        console.log("OK PHASE16 FRONTEND HANDOFF CLEANUP GUARD NO ARTIFACTS DIR");
    }
}

main();
