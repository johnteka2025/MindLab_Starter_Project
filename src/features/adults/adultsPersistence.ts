import type { AdultsScoreResult } from "./adultsScoring";

const ADULTS_PROFILE_STORAGE_KEY = "mindlab.adults.profile.v1";
const ADULTS_SESSION_HISTORY_STORAGE_KEY = "mindlab.adults.sessionHistory.v1";

export type AdultProfile = {
  ageMode: "adults";
  currentStage: string;
  currentCategory: string;
  preferredSessionMode: string;
  lastCertifiedId: string;
  masteryLevel: AdultsScoreResult["masteryLevel"] | "Developing";
  expertPathEligible: boolean;
};

export type AdultSessionHistoryItem = {
  certifiedId: string;
  sessionMode: string;
  selectedAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  score: number;
  masteryLevel: AdultsScoreResult["masteryLevel"];
  recommendation: AdultsScoreResult["recommendation"];
  expertPathEligible: boolean;
  savedAt: string;
};

export const defaultAdultProfile: AdultProfile = {
  ageMode: "adults",
  currentStage: "A1",
  currentCategory: "AC1",
  preferredSessionMode: "QuickFocus",
  lastCertifiedId: "A-AC01-A1-P01",
  masteryLevel: "Developing",
  expertPathEligible: false
};

function canUseLocalStorage(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

export function readAdultProfile(): AdultProfile {
  if (!canUseLocalStorage()) return defaultAdultProfile;

  try {
    const raw = window.localStorage.getItem(ADULTS_PROFILE_STORAGE_KEY);
    if (!raw) return defaultAdultProfile;

    return {
      ...defaultAdultProfile,
      ...JSON.parse(raw),
      ageMode: "adults"
    };
  } catch {
    return defaultAdultProfile;
  }
}

export function saveAdultProfile(profile: AdultProfile): AdultProfile {
  const safeProfile: AdultProfile = {
    ...defaultAdultProfile,
    ...profile,
    ageMode: "adults"
  };

  if (canUseLocalStorage()) {
    window.localStorage.setItem(ADULTS_PROFILE_STORAGE_KEY, JSON.stringify(safeProfile));
  }

  return safeProfile;
}

export function readAdultSessionHistory(): AdultSessionHistoryItem[] {
  if (!canUseLocalStorage()) return [];

  try {
    const raw = window.localStorage.getItem(ADULTS_SESSION_HISTORY_STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

export function recordAdultSessionResult(args: {
  certifiedId: string;
  category: string;
  stage: string;
  sessionMode: string;
  selectedAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  scoreResult: AdultsScoreResult;
}): AdultProfile {
  const historyItem: AdultSessionHistoryItem = {
    certifiedId: args.certifiedId,
    sessionMode: args.sessionMode,
    selectedAnswer: args.selectedAnswer,
    correctAnswer: args.correctAnswer,
    isCorrect: args.isCorrect,
    score: args.scoreResult.overallScore,
    masteryLevel: args.scoreResult.masteryLevel,
    recommendation: args.scoreResult.recommendation,
    expertPathEligible: args.scoreResult.expertPathEligible,
    savedAt: new Date().toISOString()
  };

  if (canUseLocalStorage()) {
    const history = readAdultSessionHistory();
    window.localStorage.setItem(
      ADULTS_SESSION_HISTORY_STORAGE_KEY,
      JSON.stringify([historyItem, ...history].slice(0, 25))
    );
  }

  return saveAdultProfile({
    ageMode: "adults",
    currentStage: args.stage,
    currentCategory: args.category,
    preferredSessionMode: args.sessionMode,
    lastCertifiedId: args.certifiedId,
    masteryLevel: args.scoreResult.masteryLevel,
    expertPathEligible: args.scoreResult.expertPathEligible
  });
}

export function resetAdultProfile(): AdultProfile {
  if (canUseLocalStorage()) {
    window.localStorage.removeItem(ADULTS_PROFILE_STORAGE_KEY);
    window.localStorage.removeItem(ADULTS_SESSION_HISTORY_STORAGE_KEY);
  }

  return defaultAdultProfile;
}
