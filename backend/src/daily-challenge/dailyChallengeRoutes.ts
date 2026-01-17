import { Router, Request, Response } from "express";
import {
  DailyChallengeInstance,
  DailyChallengePuzzleSummary,
  DailyChallengeBand,
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
} from "./dailyChallengeEngine";

/**
 * Simple in-memory store for Daily Challenge state.
 * For real production use, replace this with persistent storage.
 */

type DailyChallengeState = {
  instanceByDate: Record<string, DailyChallengeInstance>;
  streakCount: number;  answeredByDate: Record<string, Record<string, boolean>>;
};

const userStore: Record<string, DailyChallengeState> = {};

/**
 * Derive a user key from the request.
 * For now we just return a fixed key. If you have auth, replace with
 * something like req.user.id or a session identifier.
 */
function getUserKey(req: Request): string {
  return "demo-user";
}

/**
 * Determine the band for the user.
 * For now this returns "B" (Thinker) by default.
 * Later you can use a profile setting, age, or difficulty preference.
 */
function getBandForUser(req: Request): DailyChallengeBand {
  return "B";
}

function getOrCreateUserState(userKey: string): DailyChallengeState {
  let state = userStore[userKey];
  if (!state) {
    state = {
      instanceByDate: {},
      streakCount: 0,
      answeredByDate: {},
      };
    userStore[userKey] = state;
  }
  return state;
}

function generatePuzzlesForBand(
  band: DailyChallengeBand,
  dateKey: string
): DailyChallengePuzzleSummary[] {
  const config = BAND_CONFIG[band];
  const puzzles: DailyChallengePuzzleSummary[] = [];
  const count = config.puzzleCount;

  for (let i = 1; i <= count; i++) {
    puzzles.push({
      id: ${dateKey}--,
      title: Daily Puzzle ,
      type: "demo",
      difficulty: i,
    });
  }

  return puzzles;
}

function getOrCreateInstanceForToday(
  userKey: string,
  band: DailyChallengeBand,
  dateKey: string
): { state: DailyChallengeState; instance: DailyChallengeInstance } {
  const state = getOrCreateUserState(userKey);
  let instance = state.instanceByDate[dateKey];

  if (!instance) {
    const puzzles = generatePuzzlesForBand(band, dateKey);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  return { state, instance };
}

/**
 * Create an Express router with:
 *  - GET /daily/status
 *  - GET /daily
 *  - POST /daily/answer
 */
export function createDailyChallengeRouter(): Router {
  const router = Router();

  // GET /daily/status
  router.get("/daily/status", (req: Request, res: Response) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const status = deriveStatus(instance, state.streakCount);
    return res.status(200).json(status);
  });

  // GET /daily
  router.get("/daily", (req: Request, res: Response) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    // state is unused here, but we keep it for symmetry and future use.
    void state;

    return res.status(200).json(instance);
  });

  // POST /daily/answer
  router.post("/daily/answer", (req: Request, res: Response) => {
  const userKey = getUserKey(req);
  const dateKey = getTodayKey();
  const state = getOrCreateUserState(userKey);

  // Ensure today's instance exists
  let instance = state.instanceByDate[dateKey];
  if (!instance) {
    const band = getBandForUser(req);
    const puzzles = getDailyPuzzlesForBand(band);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  const body: any = req.body ?? {};

  // Rule (1): puzzleId missing -> 400
  const puzzleIdRaw = body.puzzleId;
  if (puzzleIdRaw === undefined || puzzleIdRaw === null) {
    return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
  }
  const puzzleId = String(puzzleIdRaw);

  // Rule (2): dailyChallengeId provided but not today's -> 400
  const dailyChallengeIdRaw = body.dailyChallengeId;
  const providedDailyChallengeId =
    dailyChallengeIdRaw === undefined || dailyChallengeIdRaw === null ? undefined : String(dailyChallengeIdRaw);

  if (providedDailyChallengeId && providedDailyChallengeId !== instance.dailyChallengeId) {
    return res.status(400).json({
      error: "DailyChallengeNotFound",
      message: "dailyChallengeId does not match today's challenge",
      dailyChallengeId: instance.dailyChallengeId,
    });
  }

  // Rule (4): challenge already completed -> 409
  if (instance.status === "completed") {
    return res.status(409).json({
      error: "ChallengeCompleted",
      message: "daily challenge already completed",
      dailyChallengeId: instance.dailyChallengeId,
    });
  }

  // Rule (5): puzzleId not found in today's puzzles -> 404
  const hasPuzzle = Array.isArray(instance.puzzles) && instance.puzzles.some((p: any) => String(p.id) === puzzleId);
  if (!hasPuzzle) {
    return res.status(404).json({
      error: "PuzzleNotFound",
      message: "puzzleId not found in today's puzzles",
      dailyChallengeId: instance.dailyChallengeId,
      puzzleId,
    });
  }

  // Ensure answered-by-date index exists
  if (!(state as any).answeredByDate) (state as any).answeredByDate = {};
  if (!(state as any).answeredByDate[dateKey]) (state as any).answeredByDate[dateKey] = {};

  // Rule (3): puzzle already answered -> 409
  if ((state as any).answeredByDate[dateKey][puzzleId]) {
    return res.status(409).json({
      error: "PuzzleAlreadyAnswered",
      message: "puzzle already answered",
      dailyChallengeId: instance.dailyChallengeId,
      puzzleId,
    });
  }

  // Accept answer -> 200
  const correct = true;
  const result = applyAnswer(instance, puzzleId, correct, (state as any).streakCount);

  state.instanceByDate[dateKey] = result.instance;
  (state as any).streakCount = result.streakCount;

  // Mark answered AFTER applyAnswer succeeds
  (state as any).answeredByDate[dateKey][puzzleId] = true;

  return res.status(200).json({
    dailyChallengeId: result.instance.dailyChallengeId,
    puzzleId,
    correct: result.correct,
    completedCount: result.instance.completedCount,
    totalPuzzles: result.instance.totalPuzzles,
    status: result.instance.status,
    streakCount: result.streakCount,
  });
});
    }

    if (dailyChallengeId && dailyChallengeId !== instance.dailyChallengeId) {
      return res.status(400).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId does not match today's challenge",
      });
    }

    // In this first implementation, we treat all answers as correct=true.
    // Later you can validate based on puzzle type + answer payload.
    const correct = true;

    const result = applyAnswer(
      instance,
      puzzleId,
      correct,
      state.streakCount
    );

    // Persist updated instance + streak in the in-memory store
    state.instanceByDate[dateKey] = result.instance;
    state.streakCount = result.streakCount;

    return res.status(200).json({
      dailyChallengeId: result.instance.dailyChallengeId,
      puzzleId,
      correct: result.correct,
      completedCount: result.instance.completedCount,
      totalPuzzles: result.instance.totalPuzzles,
      status: result.instance.status,
      streakCount: result.streakCount,
    });
  });

  return router;
}
