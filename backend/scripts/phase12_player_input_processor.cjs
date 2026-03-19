"use strict";

function normalizePlayerInput(input = {}) {
  return {
    playerId: input.playerId || null,
    command: input.command || "",
    payload: input.payload || {}
  };
}

module.exports = { normalizePlayerInput };
