"use strict";

const { generateDailyPuzzle } = require("./dailyPuzzle.cjs");
const { buildLeaderboardSnapshot } = require("./leaderboardSnapshot.cjs");

function buildGameOverview(scoreboardEntries) {
  const puzzle = generateDailyPuzzle();
  const leaderboard = buildLeaderboardSnapshot(scoreboardEntries);

  return {
    date: puzzle.date,
    puzzleId: puzzle.id,
    question: puzzle.question,
    difficulty: puzzle.difficulty,
    leaderboard
  };
}

module.exports = {
  buildGameOverview
};
