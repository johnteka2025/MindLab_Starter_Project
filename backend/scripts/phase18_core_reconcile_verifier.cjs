"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase18_scope_placeholder.cjs",
  "phase18_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE18_RECONCILE_VERIFIER placeholder passed");
