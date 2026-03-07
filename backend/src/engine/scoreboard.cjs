"use strict";

function normalizeEntries(entries) {
  if (!Array.isArray(entries)) {
    return [];
  }

  return entries
    .filter((x) => x && typeof x.player === "string")
    .map((x) => ({
      player: String(x.player).trim(),
      points: Number.isFinite(Number(x.points)) ? Number(x.points) : 0
    }));
}

function buildScoreboard(entries) {
  const normalized = normalizeEntries(entries);

  return normalized
    .sort((a, b) => b.points - a.points || a.player.localeCompare(b.player))
    .map((entry, index) => ({
      rank: index + 1,
      player: entry.player,
      points: entry.points
    }));
}

module.exports = {
  normalizeEntries,
  buildScoreboard
};
