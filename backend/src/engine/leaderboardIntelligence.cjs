"use strict";

const { buildLeaderboardSnapshot } = require("./leaderboardSnapshot.cjs");

function buildLeaderboardIntelligence(entries) {
  const snapshot = buildLeaderboardSnapshot(entries);
  const scoreboard = Array.isArray(snapshot.scoreboard) ? snapshot.scoreboard : [];

  const topPlayer = scoreboard.length > 0 ? scoreboard[0].player : "";
  const topPoints = scoreboard.length > 0 ? scoreboard[0].points : 0
  const gapToSecond = scoreboard.length > 1 ? scoreboard[0].points - scoreboard[1].points : 0;

  return {
    totalPlayers: snapshot.totalPlayers,
    topPlayer,
    topPoints,
    gapToSecond,
    scoreboard
  };
}

module.exports = {
  buildLeaderboardIntelligence
};
