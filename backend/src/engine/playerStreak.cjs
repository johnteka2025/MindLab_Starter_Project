"use strict";

function normalizeAttempts(attempts) {
  if (!Array.isArray(attempts)) {
    return [];
  }

  return attempts
    .filter((x) => x && typeof x.date === "string")
    .map((x) => ({
      date: String(x.date),
      ok: !!x.ok
    }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

function buildPlayerStreak(attempts) {
  const rows = normalizeAttempts(attempts);

  let currentStreak = 0;
  let bestStreak = 0;

  for (const row of rows) {
    if (row.ok) {
      currentStreak += 1;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }

  return {
    totalAttempts: rows.length,
    currentStreak,
    bestStreak
  };
}

module.exports = {
  normalizeAttempts,
  buildPlayerStreak
};
