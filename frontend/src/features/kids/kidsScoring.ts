export type KidsAnswerResult = {
  isCorrect: boolean;
  hintVisible: boolean;
  tryCount: number;
  hasAnswered: boolean;
};

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
};

function clampScore(value: number): number {
  return Math.max(0, Math.min(100, Math.round(value)));
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
      nextStep: "Choose one answer."
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

  let masteryLabel = "Growing";
  if (totalScore >= 90) {
    masteryLabel = "Super Thinker";
  } else if (totalScore >= 75) {
    masteryLabel = "Strong Focus";
  } else if (totalScore >= 60) {
    masteryLabel = "Good Start";
  }

  const encouragement = result.isCorrect
    ? "Great job. You used careful thinking."
    : "Good try. You are learning with each answer.";

  const nextStep = result.isCorrect
    ? "Try another friendly round."
    : "Use the clue, then try again.";

  return {
    totalScore,
    accuracyScore,
    effortScore,
    hintScore,
    retryScore,
    calmCompletionScore,
    masteryLabel,
    encouragement,
    nextStep
  };
}
