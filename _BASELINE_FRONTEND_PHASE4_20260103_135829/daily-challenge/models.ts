export type DailyChallengeStatusValue =
  | "not_started"
  | "in_progress"
  | "completed";

export type DailyChallengeBand = "A" | "B" | "C"; // A = Explorer, B = Thinker, C = Master

export interface DailyChallengeStatus {
  /** "not_started" | "in_progress" | "completed" */
  status: DailyChallengeStatusValue;
  /** Number of days in a row the user has completed the challenge */
  streakCount: number;
  /** How many puzzles are completed today */
  puzzlesCompletedToday: number;
  /** Total puzzles required for today's challenge */
  totalPuzzlesForToday: number;
  /** Difficulty band label ("A" | "B" | "C") */
  band: DailyChallengeBand;
  /** ISO date string for "today" on the server, e.g. "2025-11-26" */
  challengeDate: string;
}

export interface DailyChallengePuzzleSummary {
  id: string;
  /** Human-readable name or short description of the puzzle */
  title: string;
  /** Puzzle type key, e.g. "logic", "memory", "pattern" */
  type: string;
  /** Optional difficulty level (1-5, etc.) */
  difficulty?: number;
}

export interface DailyChallengeInstance {
  dailyChallengeId: string;
  band: DailyChallengeBand;
  challengeDate: string;
  totalPuzzles: number;
  completedCount: number;
  status: DailyChallengeStatusValue;
  puzzles: DailyChallengePuzzleSummary[];
}

/**
 * Response shape for GET /daily/status
 */
export interface DailyStatusResponse {
  status: DailyChallengeStatusValue;
  streakCount: number;
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  band: DailyChallengeBand;
  challengeDate: string;
}

/**
 * Response shape for GET /daily
 * This is the "full" instance information for today's challenge.
 */
export interface DailyInstanceResponse extends DailyChallengeInstance {}

/**
 * Response shape for POST /daily/answer
 */
export interface DailyAnswerResponse {
  dailyChallengeId: string;
  puzzleId: string;
  /** true if the answer was considered correct */
  correct: boolean;
  /** Updated number of completed puzzles for today */
  completedCount: number;
  /** total puzzles in the challenge */
  totalPuzzles: number;
  /** Updated overall status ("in_progress" or "completed") */
  status: DailyChallengeStatusValue;
  /** Updated streak count (only increments when the last puzzle is completed) */
  streakCount: number;
}
