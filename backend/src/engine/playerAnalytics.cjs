"use strict";

const { buildPlayerProfile } = require("./playerProfile.cjs");

function buildPlayerAnalytics(input) {
  const player = input && typeof input.player === "string" ? input.player : "";
  const attempts = input && Array.isArray(input.attempts) ? input.attempts : [];

  const profile = buildPlayerProfile(player, attempts);
  const totalAttempts = profile.summary.totalAttempts;
  const totalCorrect = profile.summary.totalCorrect;
  const totalPoints = profile.summary.totalPoints;

  const successRate = totalAttempts > 0
    ? Number(((totalCorrect / totalAttempts) * 100).toFixed(2))
    : 0;

  const avgPointsPerAttempt = totalAttempts > 0
    ? Number((totalPoints / totalAttempts).toFixed(2))
    : 0;

  return {
    player: profile.player,
    totalAttempts,
    totalCorrect,
    totalPoints,
    successRate,
    avgPointsPerAttempt,
    bestStreak: profile.streak.bestStreak
  };
}

module.exports = {
  buildPlayerAnalytics
};
