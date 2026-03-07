"use strict";

const { buildPlayerSummary } = require("./playerSummary.cjs");
const { buildPlayerStreak } = require("./playerStreak.cjs");
const { buildPlayerAchievement } = require("./playerAchievement.cjs");

function buildPlayerProfile(player, attempts) {
  const summary = buildPlayerSummary(player, attempts);

  const playerAttempts = Array.isArray(attempts)
    ? attempts.filter((x) => x && typeof x.player === "string" && String(x.player).trim() === summary.player)
    : [];

  const streak = buildPlayerStreak(playerAttempts);

  const achievement = buildPlayerAchievement({
    totalCorrect: summary.totalCorrect,
    bestStreak: streak.bestStreak,
    totalPoints: summary.totalPoints
  });

  return {
    player: summary.player,
    summary,
    streak,
    achievement
  };
}

module.exports = {
  buildPlayerProfile
};
