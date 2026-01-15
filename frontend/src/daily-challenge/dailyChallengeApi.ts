import { apiGet, apiPost } from "../api";

export type DailyChallengePuzzleSummary = {
  id: number | string;
  question: string;
};

export type DailyChallengeInstance = {
  dailyChallengeId: string; // e.g. daily-YYYYMMDD (backend returns this)
  status: "not_started" | "in_progress" | "completed";
  puzzles: DailyChallengePuzzleSummary[];
};

export type DailyChallengeStatus = {
  status: "not_started" | "in_progress" | "completed";
  progress: number;
  streak: number;
  dailyChallengeId: string;
};

export type DailyAnswerResponse = {
  ok: boolean;
};

export async function fetchDaily(): Promise<DailyChallengeInstance> {
  return apiGet<DailyChallengeInstance>("/daily");
}

export async function fetchDailyStatus(): Promise<DailyChallengeStatus> {
  return apiGet<DailyChallengeStatus>("/daily/status");
}

/**
 * Backend requires:
 * - dailyChallengeId (must match today)
 * - puzzleId (required)
 * - answer (currently ignored by backend, but we send it for forward-compat)
 */
export async function submitDailyAnswer(args: {
  dailyChallengeId: string;
  puzzleId: string;
  answer: string;
}): Promise<DailyAnswerResponse> {
  const payload = {
    dailyChallengeId: args.dailyChallengeId,
    puzzleId: args.puzzleId,
    answer: args.answer,
  };
  return apiPost<DailyAnswerResponse>("/daily/answer", payload);
}
