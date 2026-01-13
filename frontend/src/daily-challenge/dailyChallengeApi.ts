import { apiGet, apiPost } from "../api";

export type DailyChallengeBand = "A" | "B" | "C";
export type DailyChallengeStatusValue = "not_started" | "in_progress" | "completed";

export type DailyPuzzleSummary = {
  id: string;
  prompt: string;
  // Optional fields may be present depending on backend puzzle type
  choices?: string[];
};

export type DailyGetResponse = {
  dailyChallengeId: string;
  band: DailyChallengeBand;
  status: DailyChallengeStatusValue;
  puzzles: DailyPuzzleSummary[];
};

export type DailyStatusResponse = {
  dailyChallengeId: string;
  band: DailyChallengeBand;
  status: DailyChallengeStatusValue;
  progress: number;
  total: number;
  streak: number;
};

export type DailyAnswerResponse = {
  ok: boolean;
  dailyChallengeId: string;
  progress: number;
  streak: number;
  status: DailyChallengeStatusValue;
  error?: string;
  message?: string;
};

export async function fetchDaily(): Promise<DailyGetResponse> {
  return apiGet<DailyGetResponse>("/daily");
}

export async function fetchDailyStatus(): Promise<DailyStatusResponse> {
  return apiGet<DailyStatusResponse>("/daily/status");
}

export async function submitDailyAnswer(params: {
  answer: string;
  dailyChallengeId?: string;
}): Promise<DailyAnswerResponse> {
  return apiPost<DailyAnswerResponse>("/daily/answer", {
    answer: params.answer,
    dailyChallengeId: params.dailyChallengeId,
  });
}
