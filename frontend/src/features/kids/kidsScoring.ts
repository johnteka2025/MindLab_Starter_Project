export type KidsAnswerResult = {
  isCorrect: boolean;
  hintVisible: boolean;
  tryCount: number;
  hasAnswered: boolean;
};

export type KidsExceptionalLevelLabel = "Explorer" | "Builder" | "Solver" | "Mastery Spark";

export type KidsScoreBand = "NotStarted" | "Recovery" | "Starter" | "Strong" | "Exceptional";

export type KidsScoreResult = {
  totalScore: number;
  accuracyScore: number;
  effortScore: number;
  hintScore: number;
  retryScore: number;
  calmCompletionScore: number;
  masteryLabel: string;
  encouragement: string;
  nextStep: string;
  exceptionalLevel: KidsExceptionalLevelLabel;
  exceptionalLevelUnlocked: boolean;
  scoreBand: KidsScoreBand;
  growthSignal: string;
  recoveryModeSuggestion: string;
  adaptiveNextStep: string;
};

export const kidsExceptionalLevelLabels: KidsExceptionalLevelLabel[] = [
  "Explorer",
  "Builder",
  "Solver",
  "Mastery Spark"
];

function clampScore(value: number): number {
  return Math.max(0, Math.min(100, Math.round(value)));
}

export function getKidsScoreBand(totalScore: number, hasAnswered: boolean): KidsScoreBand {
  if (!hasAnswered) {
    return "NotStarted";
  }

  if (totalScore < 60) {
    return "Recovery";
  }

  if (totalScore < 75) {
    return "Starter";
  }

  if (totalScore < 90) {
    return "Strong";
  }

  return "Exceptional";
}

export function getKidsMasteryLabel(totalScore: number, hasAnswered: boolean): string {
  if (!hasAnswered) {
    return "Growing";
  }

  if (totalScore >= 90) {
    return "Super Thinker";
  }

  if (totalScore >= 75) {
    return "Strong Focus";
  }

  if (totalScore >= 60) {
    return "Good Start";
  }

  return "Growing";
}

export function getKidsExceptionalLevel(
  totalScore: number,
  isCorrect: boolean,
  tryCount: number,
  hintVisible: boolean
): KidsExceptionalLevelLabel {
  if (!isCorrect || totalScore < 75) {
    return "Explorer";
  }

  if (totalScore >= 98 && tryCount === 0 && !hintVisible) {
    return "Mastery Spark";
  }

  if (totalScore >= 90 && tryCount <= 1) {
    return "Solver";
  }

  if (totalScore >= 80) {
    return "Builder";
  }

  return "Explorer";
}

export function getKidsRecoveryModeSuggestion(isCorrect: boolean, totalScore: number): string {
  if (!isCorrect || totalScore < 60) {
    return "Try Calm Review with a gentle clue.";
  }

  if (totalScore < 75) {
    return "Repeat one friendly starter round.";
  }

  return "Keep going with another playful round.";
}

export function getKidsAdaptiveNextStep(
  isCorrect: boolean,
  totalScore: number,
  exceptionalLevel: KidsExceptionalLevelLabel
): string {
  if (!isCorrect) {
    return "Use the clue, then try a Calm Review item.";
  }

  if (exceptionalLevel === "Mastery Spark") {
    return "Offer a short challenge item with no pressure.";
  }

  if (exceptionalLevel === "Solver") {
    return "Offer a stronger reasoning or pattern item.";
  }

  if (exceptionalLevel === "Builder") {
    return "Offer a medium challenge or story practice item.";
  }

  if (totalScore >= 60) {
    return "Try another starter item.";
  }

  return "Try Calm Review next.";
}

export function calculateKidsScore(result: KidsAnswerResult): KidsScoreResult {
  if (!result.hasAnswered) {
    return {
      totalScore: 0,
      accuracyScore: 0,
      effortScore: 0,
      hintScore: 0,
      retryScore: 0,
      calmCompletionScore: 0,
      masteryLabel: "Growing",
      encouragement: "Pick an answer when you are ready.",
      nextStep: "Choose one answer.",
      exceptionalLevel: "Explorer",
      exceptionalLevelUnlocked: false,
      scoreBand: "NotStarted",
      growthSignal: "Ready to begin.",
      recoveryModeSuggestion: "Start with Play Focus.",
      adaptiveNextStep: "Choose one answer."
    };
  }

  const accuracyScore = result.isCorrect ? 100 : 40;
  const effortScore = 100;
  const hintScore = result.hintVisible ? 92 : 100;
  const retryScore = Math.max(60, 100 - result.tryCount * 5);
  const calmCompletionScore = 100;

  const totalScore = clampScore(
    accuracyScore * 0.45 +
      effortScore * 0.25 +
      hintScore * 0.15 +
      retryScore * 0.1 +
      calmCompletionScore * 0.05
  );

  const masteryLabel = getKidsMasteryLabel(totalScore, result.hasAnswered);
  const exceptionalLevel = getKidsExceptionalLevel(
    totalScore,
    result.isCorrect,
    result.tryCount,
    result.hintVisible
  );
  const scoreBand = getKidsScoreBand(totalScore, result.hasAnswered);
  const exceptionalLevelUnlocked = result.isCorrect && totalScore >= 80;
  const recoveryModeSuggestion = getKidsRecoveryModeSuggestion(result.isCorrect, totalScore);
  const adaptiveNextStep = getKidsAdaptiveNextStep(result.isCorrect, totalScore, exceptionalLevel);

  const encouragement = result.isCorrect
    ? "Great job. You used careful thinking."
    : "Good try. You are learning with each answer.";

  const nextStep = result.isCorrect
    ? adaptiveNextStep
    : "Use the clue, then try again.";

  const growthSignal = result.isCorrect
    ? `You are practicing at ${exceptionalLevel} level.`
    : "A calm retry can help this skill grow.";

  return {
    totalScore,
    accuracyScore,
    effortScore,
    hintScore,
    retryScore,
    calmCompletionScore,
    masteryLabel,
    encouragement,
    nextStep,
    exceptionalLevel,
    exceptionalLevelUnlocked,
    scoreBand,
    growthSignal,
    recoveryModeSuggestion,
    adaptiveNextStep
  };
}
