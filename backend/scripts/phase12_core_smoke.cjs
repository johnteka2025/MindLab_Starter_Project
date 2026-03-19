"use strict";

const { createGameSessionController } = require("./phase12_game_session_controller.cjs");
const { nextTurn } = require("./phase12_turn_engine.cjs");
const { createInitialGameState } = require("./phase12_game_state_manager.cjs");
const { normalizePlayerInput } = require("./phase12_player_input_processor.cjs");
const { getAiDecision } = require("./phase12_ai_decision_engine.cjs");
const { buildGameActionResponse } = require("./phase12_game_actions_api_adapter.cjs");

const controller = createGameSessionController();
const state = createInitialGameState();
const stateAfterTurn = nextTurn(state);
const input = normalizePlayerInput({ playerId: "p1", command: "move", payload: { x: 1, y: 2 } });
const ai = getAiDecision({ state: stateAfterTurn, input });
const api = buildGameActionResponse({
  stateAfterTurn,
  input,
  ai,
  session: controller.startSession({ mode: "test" })
});

if (!api.ok) {
  throw new Error("STOP: phase12 smoke failed");
}

console.log("OK: PHASE12_CORE_SMOKE passed");
