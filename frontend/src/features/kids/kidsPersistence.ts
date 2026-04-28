import type { KidsSessionModeId } from "./kidsSessionModes";

export const KIDS_PROFILE_STORAGE_KEY = "mindlab.kids.profile.v1";
export const KIDS_SESSION_HISTORY_STORAGE_KEY = "mindlab.kids.sessionHistory.v1";

export type KidsProfile = {
  ageMode: "kids";
  currentStage: string;
  currentCategory: string;
  preferredSessionMode: KidsSessionModeId;
  lastCertifiedId: string;
  lastScore: number;
  lastMasteryLabel: string;
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
  completedAt: string;
};

export const defaultKidsProfile: KidsProfile = {
  ageMode: "kids",
  currentStage: "K1",
  currentCategory: "KC1",
  preferredSessionMode: "PlayFocus",
  lastCertifiedId: "K-KC01-K1-P01",
  lastScore: 0,
  lastMasteryLabel: "Growing",
  updatedAt: new Date(0).toISOString()
};

function canUseStorage(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

export function loadKidsProfile(): KidsProfile {
  if (!canUseStorage()) {
    return defaultKidsProfile;
  }

  try {
    const raw = window.localStorage.getItem(KIDS_PROFILE_STORAGE_KEY);
    if (!raw) {
      return defaultKidsProfile;
    }

    return {
      ...defaultKidsProfile,
      ...JSON.parse(raw),
      ageMode: "kids"
    };
  } catch {
    return defaultKidsProfile;
  }
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

  try {
    const raw = window.localStorage.getItem(KIDS_SESSION_HISTORY_STORAGE_KEY);
    if (!raw) {
      return [];
    }

    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

export function appendKidsSessionHistory(entry: KidsSessionHistoryEntry): KidsSessionHistoryEntry[] {
  const nextHistory = [entry, ...loadKidsSessionHistory()].slice(0, 25);

  if (canUseStorage()) {
    window.localStorage.setItem(KIDS_SESSION_HISTORY_STORAGE_KEY, JSON.stringify(nextHistory));
  }

  return nextHistory;
}
