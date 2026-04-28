import type { KidsSessionModeId } from "./kidsSessionModes";

export const KIDS_PROFILE_STORAGE_KEY = "mindlab.kids.profile.v1";
export const KIDS_SESSION_HISTORY_STORAGE_KEY = "mindlab.kids.sessionHistory.v1";

export type KidsCategoryProgressSnapshot = {
  category: string;
  categoryName: string;
  stage: string;
  attempts: number;
  correct: number;
  bestScore: number;
  lastScore: number;
  lastMasteryLabel: string;
  lastExceptionalLevel: string;
  updatedAt: string;
};

export type KidsProfile = {
  ageMode: "kids";
  currentStage: string;
  currentCategory: string;
  preferredSessionMode: KidsSessionModeId;
  lastCertifiedId: string;
  lastScore: number;
  lastMasteryLabel: string;
  lastExceptionalLevel: string;
  lastScoreBand: string;
  lastGrowthSignal: string;
  lastRecoveryModeSuggestion: string;
  lastAdaptiveNextStep: string;
  totalSessions: number;
  correctSessions: number;
  categoryMasterySnapshot: Record<string, KidsCategoryProgressSnapshot>;
  lastCompletedAt: string;
  updatedAt: string;
};

export type KidsSessionHistoryEntry = {
  certifiedId: string;
  category: string;
  categoryName: string;
  stage: string;
  sessionMode: string;
  selectedAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  score: number;
  masteryLabel: string;
  exceptionalLevel?: string;
  exceptionalLevelUnlocked?: boolean;
  scoreBand?: string;
  growthSignal?: string;
  recoveryModeSuggestion?: string;
  adaptiveNextStep?: string;
  completedAt: string;
};

export type KidsProgressReviewSummary = {
  totalSessions: number;
  correctSessions: number;
  accuracyPercent: number;
  lastScore: number;
  lastMasteryLabel: string;
  lastExceptionalLevel: string;
  lastScoreBand: string;
  lastGrowthSignal: string;
  lastRecoveryModeSuggestion: string;
  lastAdaptiveNextStep: string;
  strongestCategory: string;
  practiceCategory: string;
  childSafeSummary: string;
};

export const defaultKidsProfile: KidsProfile = {
  ageMode: "kids",
  currentStage: "K1",
  currentCategory: "KC1",
  preferredSessionMode: "PlayFocus",
  lastCertifiedId: "K-KC01-K1-P01",
  lastScore: 0,
  lastMasteryLabel: "Growing",
  lastExceptionalLevel: "Explorer",
  lastScoreBand: "NotStarted",
  lastGrowthSignal: "Ready to begin.",
  lastRecoveryModeSuggestion: "Start with Play Focus.",
  lastAdaptiveNextStep: "Choose one answer.",
  totalSessions: 0,
  correctSessions: 0,
  categoryMasterySnapshot: {},
  lastCompletedAt: new Date(0).toISOString(),
  updatedAt: new Date(0).toISOString()
};

function canUseStorage(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

function safeParseJson<T>(raw: string | null, fallback: T): T {
  if (!raw) {
    return fallback;
  }

  try {
    return JSON.parse(raw) as T;
  } catch {
    return fallback;
  }
}

export function loadKidsProfile(): KidsProfile {
  if (!canUseStorage()) {
    return defaultKidsProfile;
  }

  const parsed = safeParseJson<Partial<KidsProfile>>(
    window.localStorage.getItem(KIDS_PROFILE_STORAGE_KEY),
    defaultKidsProfile
  );

  return {
    ...defaultKidsProfile,
    ...parsed,
    ageMode: "kids",
    categoryMasterySnapshot: parsed.categoryMasterySnapshot ?? {}
  };
}

export function saveKidsProfile(profile: Partial<KidsProfile>): KidsProfile {
  const nextProfile: KidsProfile = {
    ...loadKidsProfile(),
    ...profile,
    ageMode: "kids",
    updatedAt: new Date().toISOString()
  };

  if (canUseStorage()) {
    window.localStorage.setItem(KIDS_PROFILE_STORAGE_KEY, JSON.stringify(nextProfile));
  }

  return nextProfile;
}

export function loadKidsSessionHistory(): KidsSessionHistoryEntry[] {
  if (!canUseStorage()) {
    return [];
  }

  const parsed = safeParseJson<unknown>(
    window.localStorage.getItem(KIDS_SESSION_HISTORY_STORAGE_KEY),
    []
  );

  return Array.isArray(parsed) ? (parsed as KidsSessionHistoryEntry[]) : [];
}

export function appendKidsSessionHistory(entry: KidsSessionHistoryEntry): KidsSessionHistoryEntry[] {
  const nextHistory = [entry, ...loadKidsSessionHistory()].slice(0, 25);

  if (canUseStorage()) {
    window.localStorage.setItem(KIDS_SESSION_HISTORY_STORAGE_KEY, JSON.stringify(nextHistory));
  }

  return nextHistory;
}

export function buildKidsCategoryMasterySnapshot(
  history: KidsSessionHistoryEntry[]
): Record<string, KidsCategoryProgressSnapshot> {
  const snapshots: Record<string, KidsCategoryProgressSnapshot> = {};

  for (const entry of history) {
    const categoryKey = entry.category || "UNKNOWN";
    const current = snapshots[categoryKey] ?? {
      category: categoryKey,
      categoryName: entry.categoryName || categoryKey,
      stage: entry.stage || "K1",
      attempts: 0,
      correct: 0,
      bestScore: 0,
      lastScore: 0,
      lastMasteryLabel: "Growing",
      lastExceptionalLevel: "Explorer",
      updatedAt: entry.completedAt
    };

    snapshots[categoryKey] = {
      ...current,
      categoryName: entry.categoryName || current.categoryName,
      stage: entry.stage || current.stage,
      attempts: current.attempts + 1,
      correct: current.correct + (entry.isCorrect ? 1 : 0),
      bestScore: Math.max(current.bestScore, entry.score),
      lastScore: entry.score,
      lastMasteryLabel: entry.masteryLabel,
      lastExceptionalLevel: entry.exceptionalLevel ?? current.lastExceptionalLevel,
      updatedAt: entry.completedAt
    };
  }

  return snapshots;
}

export function recordKidsSessionProgress(entry: KidsSessionHistoryEntry): KidsProfile {
  const history = appendKidsSessionHistory(entry);
  const categoryMasterySnapshot = buildKidsCategoryMasterySnapshot(history);
  const currentProfile = loadKidsProfile();

  return saveKidsProfile({
    currentStage: entry.stage,
    currentCategory: entry.category,
    preferredSessionMode: entry.sessionMode as KidsSessionModeId,
    lastCertifiedId: entry.certifiedId,
    lastScore: entry.score,
    lastMasteryLabel: entry.masteryLabel,
    lastExceptionalLevel: entry.exceptionalLevel ?? currentProfile.lastExceptionalLevel,
    lastScoreBand: entry.scoreBand ?? currentProfile.lastScoreBand,
    lastGrowthSignal: entry.growthSignal ?? currentProfile.lastGrowthSignal,
    lastRecoveryModeSuggestion:
      entry.recoveryModeSuggestion ?? currentProfile.lastRecoveryModeSuggestion,
    lastAdaptiveNextStep: entry.adaptiveNextStep ?? currentProfile.lastAdaptiveNextStep,
    totalSessions: history.length,
    correctSessions: history.filter((item) => item.isCorrect).length,
    categoryMasterySnapshot,
    lastCompletedAt: entry.completedAt
  });
}

export function getKidsAccuracyPercent(profile: KidsProfile = loadKidsProfile()): number {
  if (profile.totalSessions <= 0) {
    return 0;
  }

  return Math.round((profile.correctSessions / profile.totalSessions) * 100);
}

export function getStrongestKidsCategory(profile: KidsProfile = loadKidsProfile()): string {
  const snapshots = Object.values(profile.categoryMasterySnapshot);

  if (snapshots.length === 0) {
    return profile.currentCategory;
  }

  const sorted = [...snapshots].sort((a, b) => b.bestScore - a.bestScore);
  return sorted[0]?.categoryName ?? profile.currentCategory;
}

export function getKidsPracticeCategory(profile: KidsProfile = loadKidsProfile()): string {
  const snapshots = Object.values(profile.categoryMasterySnapshot);

  if (snapshots.length === 0) {
    return profile.currentCategory;
  }

  const sorted = [...snapshots].sort((a, b) => a.lastScore - b.lastScore);
  return sorted[0]?.categoryName ?? profile.currentCategory;
}

export function createKidsProgressReviewSummary(
  profile: KidsProfile = loadKidsProfile()
): KidsProgressReviewSummary {
  const accuracyPercent = getKidsAccuracyPercent(profile);
  const strongestCategory = getStrongestKidsCategory(profile);
  const practiceCategory = getKidsPracticeCategory(profile);

  const childSafeSummary =
    profile.totalSessions === 0
      ? "Start with one friendly round."
      : `You practiced ${profile.totalSessions} round(s). Keep learning with a calm next step.`;

  return {
    totalSessions: profile.totalSessions,
    correctSessions: profile.correctSessions,
    accuracyPercent,
    lastScore: profile.lastScore,
    lastMasteryLabel: profile.lastMasteryLabel,
    lastExceptionalLevel: profile.lastExceptionalLevel,
    lastScoreBand: profile.lastScoreBand,
    lastGrowthSignal: profile.lastGrowthSignal,
    lastRecoveryModeSuggestion: profile.lastRecoveryModeSuggestion,
    lastAdaptiveNextStep: profile.lastAdaptiveNextStep,
    strongestCategory,
    practiceCategory,
    childSafeSummary
  };
}
