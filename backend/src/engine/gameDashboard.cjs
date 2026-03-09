"use strict";

const { buildGameOverview } = require("./gameOverview.cjs");
const { buildPlayerDashboard } = require("./playerDashboard.cjs");
const { buildLeaderboardIntelligence } = require("./leaderboardIntelligence.cjs");

function buildGameDashboard(input) {
  const player = input && typeof input.player === "string" ? input.player : "";
  const attempts = input && Array.isArray(input.attempts) ? input.attempts : [];
  const scoreboardEntries = input && Array.isArray(input.scoreboardEntries) ? input.scoreboardEntries : [];

  const overview = buildGameOverview(scoreboardEntries);
  const playerDashboard = buildPlayerDashboard(player, attempts, scoreboardEntries);
  const leaderboard = buildLeaderboardIntelligence(scoreboardEntries);

  return {
    player,
    overview,
    playerDashboard,
    leaderboard
  };
}

module.exports = {
  buildGameDashboard
};
