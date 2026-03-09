"use strict";

const { buildPlayerAnalytics } = require("./playerAnalytics.cjs");

function buildAdaptiveDifficulty(input) {
  const analytics = buildPlayerAnalytics(input || {});

  let recommendedDifficulty = "medium";

  if (analytics.successRate >= 80 && analytics.bestStreak >= 2) {
    recommendedDifficulty = "hard";
  } else if (analytics.successRate <= 40) {
    recommendedDifficulty = "easy";
  }

  return {
    player: analytics.player,
    totalAttempts: analytics.totalAttempts,
    successRate: analytics.successRate,
    bestStreak: analytics.bestStreak,
    recommendedDifficulty
  };
}

module.exports = {
  buildAdaptiveDifficulty
};
