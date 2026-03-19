"use strict";

function nextTurn(state = {}) {
  const currentTurn = Number.isInteger(state.currentTurn) ? state.currentTurn : 0;
  return {
    ...state,
    currentTurn: currentTurn + 1
  };
}

module.exports = { nextTurn };
