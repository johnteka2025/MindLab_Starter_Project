const fs = require("fs");
const path = require("path");

function todayKeyUTC() {
  const d = new Date();
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}${m}${day}`;
}

function loadAllPuzzlesFromRepo() {
  // Mirror the same "known JSON locations" pattern used elsewhere.
  // This keeps Daily Challenge stable even if you move the puzzle source later.
  const candidates = [
    path.join(__dirname, "..", "data", "index.json"),
    path.join(__dirname, "..", "puzzles", "index.json"),
    path.join(__dirname, "..", "puzzles", "index.json"), // intentional duplicate-safe
    path.join(__dirname, "..", "puzzles", "index.json"),
  ];

  let found = null;
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      found = p;
      break;
    }
  }

  if (!found) {
    // Fallback minimal list (keeps endpoints non-500 even if repo JSON path changes)
    return [
      { id: "demo-1", question: "2 + 2 = ?", answer: "4", difficulty: "easy" },
      { id: "demo-2", question: "Spell 'mind' backwards.", answer: "dnim", difficulty: "easy" },
    ];
  }

  const raw = fs.readFileSync(found, "utf8");
  const data = JSON.parse(raw);

  // Support either array-of-puzzles or { puzzles: [...] }
  const puzzles = Array.isArray(data) ? data : Array.isArray(data.puzzles) ? data.puzzles : [];
  return puzzles
    .filter((p) => p && typeof p === "object")
    .map((p, idx) => ({
      id: String(p.id ?? `p${idx + 1}`),
      question: String(p.question ?? ""),
      answer: String(p.answer ?? ""),
      difficulty: String(p.difficulty ?? ""),
    }))
    .filter((p) => p.id && p.question);
}

function buildDailyChallengeState() {
  const all = loadAllPuzzlesFromRepo();

  // Deterministic subset: first N puzzles (stable contract; avoids random flaky tests)
  const N = Math.min(10, all.length);
  const puzzles = all.slice(0, N).map((p) => ({
    id: p.id,
    question: p.question,
    // contract tests do not require answer; omit it
    difficulty: p.difficulty || undefined,
  }));

  const dailyChallengeId = `daily-${todayKeyUTC()}`;

  return {
    dailyChallengeId,
    status: "in_progress",
    puzzles,
    progress: 0,
    streak: 0,
    // keep server-side lookup for answer validation
    _allAnswers: all.reduce((acc, p) => {
      acc[p.id] = p.answer;
      return acc;
    }, {}),
    _solved: new Set(),
  };
}

module.exports = {
  buildDailyChallengeState,
};
