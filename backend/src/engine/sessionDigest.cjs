"use strict";

const { buildSessionReport } = require("./sessionReport.cjs");

function buildSessionDigest(input) {
  const report = buildSessionReport(input || {});

  return {
    player: report.player,
    status: report.status,
    ready: report.ready,
    sessionActive: report.sessionActive,
    leaderboardRank: report.leaderboardRank,
    totalPoints: report.totalPoints,
    digest: "session-ready"
  };
}

module.exports = {
  buildSessionDigest
};
