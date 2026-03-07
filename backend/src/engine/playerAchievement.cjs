"use strict";

function buildPlayerAchievement(input) {
  const totalCorrect = Number.isFinite(Number(input.totalCorrect)) ? Number(input.totalCorrect) : 0;
  const bestStreak = Number.isFinite(Number(input.bestStreak)) ? Number(input.bestStreak) : 0;
  const totalPoints = Number.isFinite(Number(input.totalPoints)) ? Number(input.totalPoints) : 0;

  const achievements = [];

  if (totalCorrect >= 1) {
    achievements.push("first-correct");
  }

  if (bestStreak >= 3) {
    achievements.push("streak-3");
  }

  if (totalPoints >= 50) {
    achievements.push("points-50");
  }

  return {
    totalCorrect,
    bestStreak,
    totalPoints,
    achievements
  };
}

module.exports = {
  buildPlayerAchievement
};
