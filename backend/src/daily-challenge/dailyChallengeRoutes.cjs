const express = require("express");
const { buildDailyChallengeState } = require("./dailyChallengeEngine.cjs");

let state = null;

function getState() {
  if (!state) state = buildDailyChallengeState();
  return state;
}

function createDailyChallengeRouter() {
  const router = express.Router();

   // GET /daily/status
  router.get("/daily/status", (req, res) => {
    const s = getState();
    return res.status(200).json({
      status: s.status,
      progress: s.progress,
      streak: s.streak,
      dailyChallengeId: s.dailyChallengeId,
    });
  });

  // POST /daily/answer
  router.post("/daily/answer", (req, res) => { 
      // POST /daily/answer
  router.post("/daily/answer", (req, res) => {
    const s = getState();

    // --- normalize body (express.json should already parse, but be defensive) ---
    let body = (req && req.body != null) ? req.body : {};
    if (typeof body === "string") {
      try { body = JSON.parse(body); } catch (_) { body = {}; }
    }
    if (!body || typeof body !== "object") body = {};

    // --- inputs (contract sends JSON: { puzzleId }) ---
    const providedDailyChallengeId = body.dailyChallengeId;

    const pidRaw = (body.puzzleId ?? body.puzzleID ?? body.puzzle_id);
    const answerRaw = body.answer;

    // --- dailyChallengeId mismatch -> 404 ---
    if (typeof providedDailyChallengeId === "string" && providedDailyChallengeId !== s.dailyChallengeId) {
      return res.status(404).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId is not current",
        dailyChallengeId: providedDailyChallengeId,
      });
    }

    // --- normalize puzzleId to non-empty string ---
    let pid = null;
    if (typeof pidRaw === "string") {
      const t = pidRaw.trim();
      pid = t.length > 0 ? t : null;
    } else if (typeof pidRaw === "number" && Number.isFinite(pidRaw)) {
      pid = String(pidRaw);
    }

    // contract: first call MUST be 200 when puzzleId present
    if (!pid) {
      return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
    }

    // contract: puzzle must exist in today's set
    if (!(pid in s._allAnswers)) {
      return res.status(404).json({ error: "PuzzleNotFound", message: "puzzleId not found in today's puzzles" });
    }

    // contract: reject answers after challenge completed -> 409
    if (s.status === "completed") {
      return res.status(409).json({ error: "ChallengeCompleted", message: "daily challenge already completed" });
    }

    // contract: reject answering same puzzle twice -> 409
    if (s._solved && s._solved.has(pid)) {
      return res.status(409).json({ error: "PuzzleAlreadyAnswered", message: "puzzle already answered" });
    }

    // answer is OPTIONAL for contract path; if missing, treat as correct (demo behavior)
    let correct = true;
    if (typeof answerRaw === "string") {
      correct = (String(s._allAnswers[pid] ?? "").toLowerCase().trim() === answerRaw.toLowerCase().trim());
    }

    // apply progress only on correct
    if (correct) {
      if (!s._solved) s._solved = new Set();
      s._solved.add(pid);

      s.progress = Math.min(s.puzzles.length, s._solved.size);

      if (s.progress >= s.puzzles.length) {
        s.status = "completed";
        s.streak = (Number(s.streak) || 0) + 1;
      }
    }

    return res.status(200).json({
      ok: correct,
      dailyChallengeId: s.dailyChallengeId,
      progress: s.progress,
      streak: s.streak,
      status: s.status,
    });
  });

  });

  return router;
}

module.exports = {
  createDailyChallengeRouter,
};
