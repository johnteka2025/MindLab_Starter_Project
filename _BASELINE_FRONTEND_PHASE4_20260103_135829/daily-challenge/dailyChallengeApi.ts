import { apiGet } from "../api";

export type DailyChallengeStatus = {
  challengeDate: string; // YYYY-MM-DD
  band: number;
  status: "not_started" | "in_progress" | "completed";
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  streakCount: number;
};

/**
 * We do not yet have a dedicated /daily/status endpoint on the backend.
 * So we derive a simple status from /puzzles + /progress to keep UI stable.
 */
export async function fetchDailyStatus(): Promise<DailyChallengeStatus> {
  const puzzles = await apiGet<any[]>("/puzzles").catch(() => []);
  const progress = await apiGet<{ total?: number; solved?: number }>("/progress").catch(() => ({}));

  const total = typeof progress.total === "number"
    ? progress.total
    : (Array.isArray(puzzles) ? puzzles.length : 0);

  const solved = typeof progress.solved === "number" ? progress.solved : 0;

  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, "0");
  const dd = String(today.getDate()).padStart(2, "0");

  const puzzlesCompletedToday = solved;
  const totalPuzzlesForToday = total;

  let status: DailyChallengeStatus["status"] = "not_started";
  if (puzzlesCompletedToday > 0 && puzzlesCompletedToday < totalPuzzlesForToday) status = "in_progress";
  if (totalPuzzlesForToday > 0 && puzzlesCompletedToday >= totalPuzzlesForToday) status = "completed";

  return {
    challengeDate: ${yyyy}--,
    band: 1,
    status,
    puzzlesCompletedToday,
    totalPuzzlesForToday,
    streakCount: 0,
  };
}
