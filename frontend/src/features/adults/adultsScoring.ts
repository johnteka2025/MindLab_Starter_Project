export type AdultsScoreInput = {
  isCorrect: boolean;
  selectedAnswer: string;
  correctAnswer: string;
  hintUse?: number;
  retryCount?: number;
  completed?: boolean;
  expectedTimeSeconds?: number;
  actualTimeSeconds?: number;
  firstTrySuccess?: boolean;
};

export type AdultsScoreResult = {
  overallScore: number;
  accuracyScore: number;
  efficiencyScore: number;
  hintIndependenceScore: number;
  retryControlScore: number;
  completionScore: number;
  masteryLevel: "NeedsSupport" | "Developing" | "Stable" | "ReadyToAdvance" | "Exceptional";
  recommendation: "Recovery" | "SameStageWithSupport" | "ContinueCurrentStage" | "Deep" | "ExpertPathCandidate";
  expertPathEligible: boolean;
};

function clampScore(value: number): number {
  return Math.max(0, Math.min(100, Math.round(value)));
}

export function calculateAdultsScore(input: AdultsScoreInput): AdultsScoreResult {
  const hintUse = input.hintUse ?? 0;
  const retryCount = input.retryCount ?? 0;
  const completed = input.completed ?? Boolean(input.selectedAnswer);
  const expectedTimeSeconds = input.expectedTimeSeconds ?? 60;
  const actualTimeSeconds = Math.max(1, input.actualTimeSeconds ?? expectedTimeSeconds);
  const firstTrySuccess = input.firstTrySuccess ?? (input.isCorrect && retryCount === 0);

  const accuracyScore = input.isCorrect ? 100 : 0;
  const efficiencyScore = clampScore((expectedTimeSeconds / actualTimeSeconds) * 100);
  const hintIndependenceScore = clampScore(100 - hintUse * 15);
  const retryControlScore = clampScore(100 - retryCount * 20);
  const completionScore = completed ? 100 : 0;

  const overallScore = clampScore(
    accuracyScore * 0.5 +
    efficiencyScore * 0.2 +
    hintIndependenceScore * 0.15 +
    retryControlScore * 0.1 +
    completionScore * 0.05
  );

  const masteryLevel = getAdultsMasteryLevel(overallScore);
  const expertPathEligible = overallScore >= 93 && firstTrySuccess && hintUse <= 0 && input.isCorrect;
  const recommendation = getAdultsRecommendation({
    overallScore,
    retryCount,
    hintUse,
    firstTrySuccess,
    isCorrect: input.isCorrect,
    expertPathEligible
  });

  return {
    overallScore,
    accuracyScore,
    efficiencyScore,
    hintIndependenceScore,
    retryControlScore,
    completionScore,
    masteryLevel,
    recommendation,
    expertPathEligible
  };
}

export function getAdultsMasteryLevel(score: number): AdultsScoreResult["masteryLevel"] {
  if (score >= 93) return "Exceptional";
  if (score >= 85) return "ReadyToAdvance";
  if (score >= 75) return "Stable";
  if (score >= 60) return "Developing";
  return "NeedsSupport";
}

export function getAdultsRecommendation(args: {
  overallScore: number;
  retryCount: number;
  hintUse: number;
  firstTrySuccess: boolean;
  isCorrect: boolean;
  expertPathEligible: boolean;
}): AdultsScoreResult["recommendation"] {
  if (args.retryCount > 3) return "Recovery";
  if (args.expertPathEligible) return "ExpertPathCandidate";
  if (args.overallScore >= 85 && args.hintUse <= 1 && args.isCorrect) return "Deep";
  if (args.overallScore >= 75) return "ContinueCurrentStage";
  return "SameStageWithSupport";
}

export function getAdultsRecommendationLabel(recommendation: AdultsScoreResult["recommendation"]): string {
  const labels: Record<AdultsScoreResult["recommendation"], string> = {
    Recovery: "Try Recovery",
    SameStageWithSupport: "Retry with support",
    ContinueCurrentStage: "Continue current stage",
    Deep: "Try Deep",
    ExpertPathCandidate: "Expert path candidate"
  };

  return labels[recommendation];
}
