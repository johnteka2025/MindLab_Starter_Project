/**
 * Daily Challenge API client
 * Talks to backend /daily endpoints.
 */

export type DailyStatusValue = "not_started" | "in_progress" | "completed";

export interface DailyChallengeStatus {
  status: DailyStatusValue;
  streakCount: number;
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  band: string;
  challengeDate: string; // ISO yyyy-mm-dd
}

export interface DailyChallengePuzzle {
  id: string;
  title: string;
  type: string;
  difficulty: number;
}

export interface DailyChallengeInstance {
  dailyChallengeId: string;
  band: string;
  challengeDate: string; // ISO yyyy-mm-dd
  totalPuzzles: number;
  completedCount: number;
  status: DailyStatusValue;
  puzzles: DailyChallengePuzzle[];
}

export interface DailyAnswerRequest {
  dailyChallengeId: string;
  puzzleId: string;
  answer: string;
}

export interface DailyAnswerResponse {
  dailyChallengeId: string;
  puzzleId: string;
  correct: boolean;
  completedCount: number;
  totalPuzzles: number;
  status: DailyStatusValue;
  streakCount: number;
}

/**
 * Helper to call JSON endpoints and surface nice errors.
 */
async function fetchJson<T>(input: RequestInfo, init?: RequestInit): Promise<T> {
  const response = await fetch(input, {
    headers: {
      "Content-Type": "application/json",
      ...(init && init.headers ? init.headers : {}),
    },
    ...init,
  });

  if (!response.ok) {
    let message = `HTTP ${response.status}`;
    try {
      const text = await response.text();
      if (text) {
        message += ` - ${text}`;
      }
    } catch {
      // ignore
    }
    throw new Error(message);
  }

  return (await response.json()) as T;
}

/**
 * Fetches a lightweight status object for today (no puzzle list).
 * GET /daily/status
 */
export function fetchDailyStatus(): Promise<DailyChallengeStatus> {
  return fetchJson<DailyChallengeStatus>("/daily/status", {
    method: "GET",
  });
}

/**
 * Fetches the full Daily Challenge instance for today.
 * GET /daily
 */
export function fetchDailyInstance(): Promise<DailyChallengeInstance> {
  return fetchJson<DailyChallengeInstance>("/daily", {
    method: "GET",
  });
}

/**
 * Submits an answer to a single puzzle.
 * POST /daily/answer
 */
export function submitDailyAnswer(
  payload: DailyAnswerRequest
): Promise<DailyAnswerResponse> {
  return fetchJson<DailyAnswerResponse>("/daily/answer", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}
