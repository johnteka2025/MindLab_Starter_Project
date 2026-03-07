"use strict";

function normalizeAttempts(attempts) {
  if (!Array.isArray(attempts)) {
    return [];
  }

  return attempts
    .filter((x) => x && typeof x.player === "string")
    .map((x) => ({
      player: String(x.player).trim(),
      date: typeof x.date === "string" ? x.date : "",
      ok: !!x.ok,
      points: Number.isFinite(Number(x.points)) ? Number(x.points) : 0
    }));
}

function buildPlayerHistory(player, attempts) {
  const normalizedPlayer = typeof player === "string" ? player.trim() : "";
  const rows = normalizeAttempts(attempts).filter((x) => x.player === normalizedPlayer);

  const totalPoints = rows.reduce((sum, row) => sum + row.points, 0);
  const totalCorrect = rows.filter((row) => row.ok).length;

  return {
    player: normalizedPlayer,
    totalAttempts: rows.length,
    totalCorrect,
    totalPoints,
    history: rows
  };
}

module.exports = {
  normalizeAttempts,
  buildPlayerHistory
};
