module.exports = function (app) {
  // Single source of truth stored on globalThis so all routes share it
  if (!globalThis.__mindlabProgress) {
    globalThis.__mindlabProgress = {
      total: 2,
      solved: 0,
      solvedToday: 0,
      totalSolved: 0,
      streak: 0
    };
  }

  function clampProgress() {
    const p = globalThis.__mindlabProgress;
    if (typeof p.total !== "number") p.total = 2;
    if (typeof p.solved !== "number") p.solved = 0;
    if (p.solved < 0) p.solved = 0;
    if (p.solved > p.total) p.solved = p.total;
  }

  // GET /progress -> always returns the SAME store
  app.get("/progress", (req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;
    return res.json({ total: p.total, solved: p.solved });
  });

  // POST /progress/solve { puzzleId } -> updates SAME store then returns it
  app.post("/progress/solve", (req, res) => {
    try {
      const puzzleId = req.body && req.body.puzzleId;
      const p = globalThis.__mindlabProgress;

      clampProgress();
      p.solved = Math.min(p.total, p.solved + 1);

      // Optional: keep these fields coherent (safe defaults)
      p.solvedToday = (typeof p.solvedToday === "number" ? p.solvedToday : 0) + 1;
      p.totalSolved = (typeof p.totalSolved === "number" ? p.totalSolved : 0) + 1;
      p.streak = (typeof p.streak === "number" ? p.streak : 0);
      if (p.solvedToday > 0) p.streak = Math.max(1, p.streak);

      return res.status(200).json({
        ok: true,
        puzzleId,
        progress: { total: p.total, solved: p.solved, solvedToday: p.solvedToday, totalSolved: p.totalSolved, streak: p.streak }
      });
    } catch (e) {
      return res.status(500).json({ ok: false, error: String(e) });
    }
  });

  // Legacy compatibility (if anything still calls POST /progress)
  app.post("/progress", (req, res) => {
    // If caller sends { correct: true }, treat as solve
    const body = req.body || {};
    if (body.correct === true) {
      const p = globalThis.__mindlabProgress;
      clampProgress();
      p.solved = Math.min(p.total, p.solved + 1);
    }
    clampProgress();
    const p = globalThis.__mindlabProgress;
    return res.json({ total: p.total, solved: p.solved });
  });
};
