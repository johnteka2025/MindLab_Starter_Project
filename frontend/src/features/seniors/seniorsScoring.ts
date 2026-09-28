export type SeniorsConfidenceMilestone =
  | "Building Confidence"
  | "Steady Progress"
  | "Strong Confidence"
  | "Comfortable Mastery";

export type SeniorsScoreInput = {
  isCorrect: boolean;
  completed?: boolean;
  elapsedSeconds?: number;
  hintUsed?: boolean;
};

export type SeniorsScoreResult = {
  overallScore: number;
  accuracyScore: number;
  completionScore: number;
  confidenceMilestone: SeniorsConfidenceMilestone;
  measuredSeconds: number;
};

function clampScore(value: number): number {
  return Math.max(0, Math.min(100, Math.round(value)));
}

export function getSeniorsConfidenceMilestone(score: number): SeniorsConfidenceMilestone {
  if (score >= 95) return "Comfortable Mastery";
  if (score >= 85) return "Strong Confidence";
  if (score >= 70) return "Steady Progress";
  return "Building Confidence";
}

export function calculateSeniorsScore(input: SeniorsScoreInput): SeniorsScoreResult {
  const completed = input.completed ?? true;
  const accuracyScore = input.isCorrect ? 100 : 60;
  const completionScore = completed ? 100 : 0;

  const overallScore = clampScore(
    accuracyScore * 0.75 +
    completionScore * 0.25
  );

  return {
    overallScore,
    accuracyScore,
    completionScore,
    confidenceMilestone: getSeniorsConfidenceMilestone(overallScore),
    measuredSeconds: Math.max(0, Math.round(input.elapsedSeconds ?? 0))
  };
}
