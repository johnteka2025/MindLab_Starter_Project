"use strict";

function createInitialGameState() {
  return {
    currentTurn: 0,
    status: "idle",
    players: [],
    history: []
  };
}

module.exports = { createInitialGameState };
