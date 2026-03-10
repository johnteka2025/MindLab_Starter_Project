"use strict";

const fs = require("fs");
const path = require("path");

const targetFile = path.join(__dirname, "..", "artifacts", "phase16_client_snapshot.json");

function main() {
    if (fs.existsSync(targetFile)) {
        fs.unlinkSync(targetFile);
        console.log("OK PHASE16 ARTIFACT CLEANUP REMOVED FILE");
    } else {
        console.log("OK PHASE16 ARTIFACT CLEANUP NO FILE");
    }

    console.log(targetFile);
}

main();
