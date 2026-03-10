"use strict";

const fs = require("fs");
const path = require("path");

const targetDir = path.join(__dirname, "..", "artifacts");
const targetFile = path.join(targetDir, "phase16_client_snapshot.json");

function main() {
    if (fs.existsSync(targetFile)) {
        fs.unlinkSync(targetFile);
        console.log("OK PHASE16 ARTIFACT CLEANUP REMOVED FILE");
    } else {
        console.log("OK PHASE16 ARTIFACT CLEANUP NO FILE");
    }

    if (fs.existsSync(targetDir)) {
        const remaining = fs.readdirSync(targetDir);
        if (remaining.length === 0) {
            fs.rmdirSync(targetDir);
            console.log("OK PHASE16 ARTIFACT CLEANUP REMOVED DIR");
        } else {
            console.log("OK PHASE16 ARTIFACT CLEANUP DIR NOT EMPTY");
        }
    } else {
        console.log("OK PHASE16 ARTIFACT CLEANUP NO DIR");
    }

    console.log(targetDir);
}

main();
