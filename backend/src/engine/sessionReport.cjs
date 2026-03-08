"use strict";

const { buildSessionSummary } = require("./sessionSummary.cjs");
const { buildSessionOverview } = require("./sessionOverview.cjs");

function buildSessionReport(input) {
  const summary = buildSessionSummary(input || {});
  const overview = buildSessionOverview(input || {});

  return {
    player: summary.player,
    status: summary.status,
    ready: summary.ready,
    sessionActive: summary.sessionActive,
    leaderboardRank: summary.leaderboardRank,
    totalPoints: summary.totalPoints,
    overview
  };
}

module.exports = {
  buildSessionReport
};
