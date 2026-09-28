const SENIORS_SESSION_HISTORY_STORAGE_KEY = "mindlab.seniors.sessionHistory.v1";

export type SeniorsPersistenceRecord = {
  sessionMode: string;
  challengeId: string;
  isCorrect: boolean;
  score: number;
  hintUsed: boolean;
  elapsedSeconds: number;
  practiceCategory: string;
  completedAt: string;
};

function canUseLocalStorage(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

export function buildSeniorsPersistenceRecord(args: {
  sessionMode: string;
  challengeId: string;
  isCorrect: boolean;
  score: number;
  hintUsed: boolean;
  elapsedSeconds: number;
  practiceCategory: string;
  completedAt?: string;
}): SeniorsPersistenceRecord {
  return {
    sessionMode: args.sessionMode,
    challengeId: args.challengeId,
    isCorrect: args.isCorrect,
    score: Math.max(0, Math.min(100, Math.round(args.score))),
    hintUsed: Boolean(args.hintUsed),
    elapsedSeconds: Math.max(0, Math.round(args.elapsedSeconds)),
    practiceCategory: args.practiceCategory,
    completedAt: args.completedAt ?? new Date().toISOString()
  };
}

export function readSeniorsSessionHistory(): SeniorsPersistenceRecord[] {
  if (!canUseLocalStorage()) return [];

  try {
    const raw = window.localStorage.getItem(SENIORS_SESSION_HISTORY_STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

export function recordSeniorsChallengeResult(
  args: Parameters<typeof buildSeniorsPersistenceRecord>[0]
): SeniorsPersistenceRecord {
  const record = buildSeniorsPersistenceRecord(args);

  if (canUseLocalStorage()) {
    const history = readSeniorsSessionHistory();
    window.localStorage.setItem(
      SENIORS_SESSION_HISTORY_STORAGE_KEY,
      JSON.stringify([record, ...history].slice(0, 30))
    );
  }

  return record;
}

export function resetSeniorsSessionHistory(): void {
  if (canUseLocalStorage()) {
    window.localStorage.removeItem(SENIORS_SESSION_HISTORY_STORAGE_KEY);
  }
}
