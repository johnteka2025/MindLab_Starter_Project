"use strict";

const { buildPlayerAnalytics } = require("./playerAnalytics.cjs");
const { buildAdaptiveDifficulty } = require("./adaptiveDifficulty.cjs");

function buildPlayerStats(input) {
  const analytics = buildPlayerAnalytics(input || {});
  const adaptive = buildAdaptiveDifficulty(input || {});

  return {
    player: analytics.player,
    totalAttempts: analytics.totalAttempts,
    totalCorrect: analytics.totalCorrect,
    totalPoints: analytics.totalPoints,
    successRate: analytics.successRate,
    avgPointsPerAttempt: analytics.avgPointsPerAttempt,
    bestStreak: analytics.bestStreak,
    recommendedDifficulty: adaptive.recommendedDifficulty
  };
}

module.exports = {
  buildPlayerStats
};
