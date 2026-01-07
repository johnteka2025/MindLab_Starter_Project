module.exports = function (app) {
  // Single source of truth stored on globalThis so all routes share it
  if (!globalThis.__mindlabProgress) {
    globalThis.__mindlabProgress = {
      total: 2,
      solved: 0,
      solvedToday: 0,
      totalSolved: 0,
      streak: 0,
      solvedPuzzleIds: {}
    };
  }

  function clampProgress() {
    const p = globalThis.__mindlabProgress;

    if (typeof p.total !== "number") p.total = 2;
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

  // GET /progress -> returns minimal contract shape
  app.get("/progress", (req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;
    return res.json({ total: p.total, solved: p.solved });
  });

  // POST /progress/solve { puzzleId } -> updates store then returns detailed state
  app.post("/progress/solve", (req, res) => {
    try {
      clampProgress();
      const p = globalThis.__mindlabProgress;

      const body = req.body || {};
      const puzzleId = body.puzzleId || body.id || body.puzzle || null;

      // If we have a puzzleId, avoid double-counting the same puzzle in one run
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
          streak: p.streak
        }
      });
    } catch (e) {
      return res.status(500).json({ ok: false, error: String(e) });
    }
  });

  // Legacy compatibility (if anything still calls POST /progress)
  // If caller sends { correct: true }, treat as solve.
  app.post("/progress", (req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;

    const body = req.body || {};
    if (body.correct === true) {
      p.solved = Math.min(p.total, p.solved + 1);
    }

    clampProgress();
    return res.json({ total: p.total, solved: p.solved });
  });
};
