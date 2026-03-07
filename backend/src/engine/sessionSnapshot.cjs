"use strict";

const { buildGameOverview } = require("./gameOverview.cjs");
const { buildPlayerDashboard } = require("./playerDashboard.cjs");

function buildSessionSnapshot(input) {
  const player = input && typeof input.player === "string" ? input.player : "";
  const attempts = input && Array.isArray(input.attempts) ? input.attempts : [];
  const scoreboardEntries = input && Array.isArray(input.scoreboardEntries) ? input.scoreboardEntries : [];

  const overview = buildGameOverview(scoreboardEntries);
  const dashboard = buildPlayerDashboard(player, attempts, scoreboardEntries);

  return {
    player: dashboard.player,
    overview,
    dashboard
  };
}

module.exports = {
  buildSessionSnapshot
};
