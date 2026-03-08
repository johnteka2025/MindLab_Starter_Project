"use strict";

const { buildSessionOverview } = require("./sessionOverview.cjs");

function buildSessionSummary(input) {
  const overview = buildSessionOverview(input || {});

  return {
    player: overview.player,
    status: overview.status,
    ready: overview.ready,
    sessionActive: overview.sessionActive,
    leaderboardRank: overview.snapshot && overview.snapshot.dashboard && overview.snapshot.dashboard.leaderboard
      ? overview.snapshot.dashboard.leaderboard.rank
      : null,
    totalPoints: overview.snapshot && overview.snapshot.dashboard && overview.snapshot.dashboard.profile && overview.snapshot.dashboard.profile.summary
      ? overview.snapshot.dashboard.profile.summary.totalPoints
      : 0
  };
}

module.exports = {
  buildSessionSummary
};
