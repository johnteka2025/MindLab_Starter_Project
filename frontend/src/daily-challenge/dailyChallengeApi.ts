import { apiGet, apiPost } from "../api";

export type DailyChallengePuzzleSummary = {
  id: string | number;
  question: string;
  options?: string[];
  correctIndex?: number;
};

export type DailyChallengeInstance = {
  dailyChallengeId?: string;
  puzzles: DailyChallengePuzzleSummary[];
  [k: string]: unknown;
};

export type DailyChallengeStatus = {
  challengeDate: string; // YYYY-MM-DD
  band: number;
  status: "not_started" | "in_progress" | "completed";
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  streakCount: number;
};

export type DailyAnswerResponse = {
  ok: boolean;
  correct?: boolean;
  message?: string;
  dailyChallengeId?: string;
  progress?: number;
  streak?: number;
  status?: string;
  [k: string]: unknown;
};

export async function fetchDaily(): Promise<DailyChallengeInstance> {
  return apiGet<DailyChallengeInstance>("/daily");
}

export async function fetchDailyStatus(): Promise<DailyChallengeStatus> {
  return apiGet<DailyChallengeStatus>("/daily/status");
}

export async function submitDailyAnswer(
  answer: string,
  puzzleId?: string | number
): Promise<DailyAnswerResponse> {
  const payload: Record<string, unknown> = { answer };
  if (puzzleId !== undefined && puzzleId !== null && String(puzzleId).length > 0) payload.puzzleId = puzzleId;
  return apiPost<DailyAnswerResponse>("/daily/answer", payload);
}
