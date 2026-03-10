"use strict";

const fs = require("fs");
const path = require("path");
const manifest = require("./phase16_frontend_handoff_manifest.cjs");
const snapshot = require("./phase16_client_snapshot_export.cjs");

const outDir = path.join(__dirname, "..", "artifacts", "frontend-handoff");
const manifestFile = path.join(outDir, "manifest.json");
const snapshotFile = path.join(outDir, "snapshot.json");

function main() {
    if (fs.existsSync(outDir)) {
        fs.rmSync(outDir, { recursive: true, force: true });
    }

    fs.mkdirSync(outDir, { recursive: true });
    fs.writeFileSync(manifestFile, JSON.stringify(manifest, null, 2) + "\n", "utf8");
    fs.writeFileSync(snapshotFile, JSON.stringify(snapshot, null, 2) + "\n", "utf8");

    console.log("OK PHASE16 FRONTEND HANDOFF PACKAGE WRITER PASSED");
    console.log(outDir);
}

main();
