"use strict";

const fs = require("fs");
const path = require("path");
const snapshot = require("./phase16_client_snapshot_export.cjs");

const outDir = path.join(__dirname, "..", "artifacts");
const outFile = path.join(outDir, "phase16_client_snapshot.json");

function main() {
    if (fs.existsSync(outFile)) {
        fs.unlinkSync(outFile);
    }

    fs.mkdirSync(outDir, { recursive: true });
    fs.writeFileSync(outFile, JSON.stringify(snapshot, null, 2) + "\n", "utf8");

    console.log("OK PHASE16 SNAPSHOT WRITER PASSED");
    console.log(outFile);
}

main();
