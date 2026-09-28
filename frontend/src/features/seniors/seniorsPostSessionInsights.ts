import type {
  SeniorsConfidenceMilestone,
  SeniorsScoreResult
} from "./seniorsScoring";

export type SeniorsPostSessionInsight = {
  title: string;
  message: string;
  nextStep: string;
};

export type SeniorsSessionRoundResult = {
  challengeId: string;
  isCorrect: boolean;
  score: number;
  elapsedSeconds: number;
  practiceCategory: string;
};

export type SeniorsSessionSummary = {
  challengesCompleted: number;
  correctAnswers: number;
  averageScore: number;
  confidenceMilestone: SeniorsConfidenceMilestone;
  practiceArea: string;
  recommendedNextStep: string;
  measuredSeconds: number;
};

export function getSeniorsPostSessionInsight(
  scoreResult: SeniorsScoreResult,
  isCorrect: boolean,
  itemInsight: string
): SeniorsPostSessionInsight {
  if (isCorrect && scoreResult.confidenceMilestone === "Comfortable Mastery") {
    return {
      title: "Comfortable mastery",
      message: itemInsight,
      nextStep: "Continue when you feel ready, or try another familiar mode."
    };
  }

  if (isCorrect) {
    return {
      title: "Steady progress",
      message: itemInsight,
      nextStep: "Continue at the same calm pace."
    };
  }

  return {
    title: "Keep building confidence",
    message: "That one was challenging. Review the clue and the correct answer, then continue when you are ready.",
    nextStep: "A hint or Calm Review can provide extra support."
  };
}

export function getSeniorsSessionSummary(
  results: SeniorsSessionRoundResult[]
): SeniorsSessionSummary {
  const challengesCompleted = results.length;
  const correctAnswers = results.filter((result) => result.isCorrect).length;
  const averageScore = challengesCompleted > 0
    ? Math.round(results.reduce((sum, result) => sum + result.score, 0) / challengesCompleted)
    : 0;
  const measuredSeconds = results.reduce((sum, result) => sum + result.elapsedSeconds, 0);
  const firstPracticeNeed = results.find((result) => !result.isCorrect)?.practiceCategory;
  const practiceArea = firstPracticeNeed ?? results[0]?.practiceCategory ?? "Steady mixed practice";

  let recommendedNextStep = "Continue with another comfortable round.";
  if (correctAnswers <= 1) {
    recommendedNextStep = "Try Calm Review with a hint when useful.";
  } else if (correctAnswers === challengesCompleted && challengesCompleted > 0) {
    recommendedNextStep = "Try Pattern Confidence or another familiar round.";
  }

  let confidenceMilestone: SeniorsConfidenceMilestone = "Building Confidence";
  if (averageScore >= 95) {
    confidenceMilestone = "Comfortable Mastery";
  } else if (averageScore >= 85) {
    confidenceMilestone = "Strong Confidence";
  } else if (averageScore >= 70) {
    confidenceMilestone = "Steady Progress";
  }

  return {
    challengesCompleted,
    correctAnswers,
    averageScore,
    confidenceMilestone,
    practiceArea,
    recommendedNextStep,
    measuredSeconds
  };
}
