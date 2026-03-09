"use strict";

const { buildSessionMetrics } = require("./sessionMetrics.cjs");

function buildSessionMetricsSummary(input) {
  const metrics = buildSessionMetrics(input || {});

  return {
    player: metrics.player,
    totalAttempts: metrics.totalAttempts,
    totalPoints: metrics.totalPoints,
    leaderboardRank: metrics.leaderboardRank,
    avgPointsPerAttempt: metrics.avgPointsPerAttempt,
    summaryLabel: "metrics-ready"
  };
}

module.exports = {
  buildSessionMetricsSummary
};
