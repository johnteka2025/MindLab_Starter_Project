// C:\Projects\MindLab_Starter_Project\backend\src\progressRoutes.cjs
"use strict";

const fs = require("fs");
const path = require("path");

module.exports = function (app) {
  // Single source of truth stored on globalThis so all routes share it
  if (!globalThis.__mindlabProgress) {
    globalThis.__mindlabProgress = {
      total: 0, // will be recalculated dynamically
      solved: 0,
      solvedToday: 0,
      totalSolved: 0,
      streak: 0,
      solvedPuzzleIds: {}, // { [puzzleId]: true }
    };
  }

  function readPuzzlesCount() {
    // Keep this aligned with server.cjs candidates list (avoid drift)
    const candidates = [
      path.join(__dirname, "index.json"),
      path.join(__dirname, "puzzles", "index.json"),
      path.join(__dirname, "puzzles", "index.json"),
      path.join(__dirname, "puzzles.json"),
      path.join(__dirname, "puzzles", "legacy", "puzzles.json"),
    ];

    for (const p of candidates) {
      try {
        if (!fs.existsSync(p)) continue;
        const raw = fs.readFileSync(p, "utf8");
        const data = JSON.parse(raw);

        // Support either array or { puzzles: [] }
        const puzzles = Array.isArray(data)
          ? data
          : Array.isArray(data.puzzles)
          ? data.puzzles
          : [];

        if (Array.isArray(puzzles)) return puzzles.length;
      } catch {
        // ignore and try next candidate
      }
    }

    // Fallback matches server.cjs fallback list size (2)
    return 2;
  }

  function clampProgress() {
    const p = globalThis.__mindlabProgress;

    const computedTotal = readPuzzlesCount();
    p.total = typeof computedTotal === "number" ? computedTotal : 2;

    if (typeof p.solved !== "number") p.solved = 0;

    if (p.total < 0) p.total = 0;
    if (p.solved < 0) p.solved = 0;
    if (p.solved > p.total) p.solved = p.total;

    if (typeof p.solvedToday !== "number") p.solvedToday = 0;
    if (typeof p.totalSolved !== "number") p.totalSolved = 0;
    if (typeof p.streak !== "number") p.streak = 0;

    if (!p.solvedPuzzleIds || typeof p.solvedPuzzleIds !== "object") {
      p.solvedPuzzleIds = {};
    }
  }

  function solvedIdsArray() {
    const p = globalThis.__mindlabProgress;
    return Object.keys(p.solvedPuzzleIds || {});
  }

  function doSolve(req, res) {
    try {
      clampProgress();
      const p = globalThis.__mindlabProgress;

      const body = req.body || {};
      const puzzleId = body.puzzleId || body.id || body.puzzle || null;

      // Avoid double-counting the same puzzle in one run
      if (puzzleId && !p.solvedPuzzleIds[puzzleId]) {
        p.solvedPuzzleIds[puzzleId] = true;
        p.solved = Math.min(p.total, p.solved + 1);
        p.solvedToday += 1;
        p.totalSolved += 1;
      } else if (!puzzleId) {
        // No puzzleId: still treat as a solve request, but clamp carefully
        p.solved = Math.min(p.total, p.solved + 1);
        p.solvedToday += 1;
        p.totalSolved += 1;
      }

      clampProgress();

      return res.status(200).json({
        ok: true,
        puzzleId: puzzleId,
        progress: {
          total: p.total,
          solved: p.solved,
          solvedToday: p.solvedToday,
          totalSolved: p.totalSolved,
          streak: p.streak,
          solvedIds: solvedIdsArray(),
        },
      });
    } catch (e) {
      return res.status(500).json({ ok: false, error: String(e) });
    }
  }

  // GET /progress -- now includes solvedIds for UI
  app.get("/progress", (_req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;
    return res.json({
      total: p.total,
      solved: p.solved,
      solvedIds: solvedIdsArray(),
    });
  });

  // POST /progress/solve
  app.post("/progress/solve", (req, res) => doSolve(req, res));

  // Legacy compatibility: POST /progress
  app.post("/progress", (req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;

    const body = req.body || {};
    if (body.correct === true) {
      p.solved = Math.min(p.total, p.solved + 1);
    }

    clampProgress();
    return res.json({
      total: p.total,
      solved: p.solved,
      solvedIds: solvedIdsArray(),
    });
  });

  // Optional reset for testing
  app.post("/progress/reset", (_req, res) => {
    const p = globalThis.__mindlabProgress;
    p.solved = 0;
    p.solvedToday = 0;
    p.totalSolved = 0;
    p.streak = 0;
    p.solvedPuzzleIds = {};
    clampProgress();
    return res.json({
      ok: true,
      total: p.total,
      solved: p.solved,
      solvedIds: [],
    });
  });
};
