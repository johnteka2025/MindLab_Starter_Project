"use strict";

const fs = require("fs");
const path = require("path");

const required = [
  "phase12_game_session_controller.cjs",
  "phase12_turn_engine.cjs",
  "phase12_game_state_manager.cjs",
  "phase12_player_input_processor.cjs",
  "phase12_ai_decision_engine.cjs",
  "phase12_game_actions_api_adapter.cjs",
  "phase12_core_smoke.cjs"
];

const base = __dirname;

for (const file of required) {
  const full = path.join(base, file);
  if (!fs.existsSync(full)) {
    throw new Error("STOP: missing " + full);
  }
}

console.log("OK: PHASE12_RECONCILE_VERIFIER passed");
