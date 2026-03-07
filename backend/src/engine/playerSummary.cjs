"use strict";

const { buildPlayerHistory } = require("./playerHistory.cjs");

function buildPlayerSummary(player, attempts) {
  const historyResult = buildPlayerHistory(player, attempts);

  const accuracy = historyResult.totalAttempts > 0
    ? Number(((historyResult.totalCorrect / historyResult.totalAttempts) * 100).toFixed(2))
    : 0;

  return {
    player: historyResult.player,
    totalAttempts: historyResult.totalAttempts,
    totalCorrect: historyResult.totalCorrect,
    totalPoints: historyResult.totalPoints,
    accuracy
  };
}

module.exports = {
  buildPlayerSummary
};
