"use strict";

const { buildSessionSnapshot } = require("./sessionSnapshot.cjs");

function buildGameState(input) {
  const snapshot = buildSessionSnapshot(input || {});
  const player = snapshot.player || "";

  return {
    player,
    status: "ready",
    snapshot
  };
}

module.exports = {
  buildGameState
};
