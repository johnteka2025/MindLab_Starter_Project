"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase13_scope_placeholder.cjs",
  "phase13_core_smoke.cjs"
];

for (const file of required) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE13_RECONCILE_VERIFIER placeholder passed");
