"use strict";

const { buildPlayerProfile } = require("./playerProfile.cjs");
const { buildLeaderboardSnapshot } = require("./leaderboardSnapshot.cjs");

function buildPlayerDashboard(player, attempts, scoreboardEntries) {
  const profile = buildPlayerProfile(player, attempts);
  const leaderboard = buildLeaderboardSnapshot(scoreboardEntries);

  const leaderboardRow = Array.isArray(leaderboard.scoreboard)
    ? leaderboard.scoreboard.find((x) => x && x.player === profile.player)
    : null;

  return {
    player: profile.player,
    profile,
    leaderboard: {
      rank: leaderboardRow ? leaderboardRow.rank : null,
      points: leaderboardRow ? leaderboardRow.points : 0,
      totalPlayers: leaderboard.totalPlayers
    }
  };
}

module.exports = {
  buildPlayerDashboard
};
