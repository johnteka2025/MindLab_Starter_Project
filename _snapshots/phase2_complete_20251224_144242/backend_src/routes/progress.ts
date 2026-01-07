import { Router } from "express";

export const progressRouter = Router();

/**
 * In-memory progress (Phase 2 baseline).
 * If you already have a progress store elsewhere, we will merge later.
 */
let solvedCount = 0;

// Optional: track unique puzzle IDs so repeated clicks don't inflate solved.
const solvedIds = new Set<string>();

// GET /progress -> { total: number, solved: number }
progressRouter.get("/", (_req, res) => {
  // NOTE: total is currently 2 in your backend response.
  // If you have a puzzles store, replace this with puzzles.length.
  const total = 2;
  res.json({ total, solved: solvedCount });
});

// POST /progress/solve -> { ok: true, total, solved }
progressRouter.post("/solve", (req, res) => {
  const { puzzleId } = req.body ?? {};

  if (!puzzleId || typeof puzzleId !== "string") {
    return res.status(400).json({ error: "puzzleId (string) is required" });
  }

  // Avoid double-counting the same puzzle
  if (!solvedIds.has(puzzleId)) {
    solvedIds.add(puzzleId);
    solvedCount += 1;
  }

  const total = 2;
  res.json({ ok: true, total, solved: solvedCount });
});
