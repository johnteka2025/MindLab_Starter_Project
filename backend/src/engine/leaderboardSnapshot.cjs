"use strict";

const { buildScoreboard } = require("./scoreboard.cjs");

function buildLeaderboardSnapshot(entries) {
  const scoreboard = buildScoreboard(entries);

  return {
    createdAt: new Date().toISOString(),
    totalPlayers: scoreboard.length,
    scoreboard
  };
}

module.exports = {
  buildLeaderboardSnapshot
};
