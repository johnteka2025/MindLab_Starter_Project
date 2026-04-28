import type { AdultsScoreResult } from "./adultsScoring";
import { getAdultsRecommendationLabel } from "./adultsScoring";

export type AdultsPostSessionInsight = {
  title: string;
  message: string;
  recommendationLabel: string;
  tone: "Supportive" | "Practical" | "Confident" | "Mastery";
};

export function getAdultsPostSessionInsight(
  scoreResult: AdultsScoreResult,
  isCorrect: boolean,
  itemInsight: string
): AdultsPostSessionInsight {
  if (scoreResult.expertPathEligible || scoreResult.masteryLevel === "Exceptional") {
    return {
      title: "Excellent control",
      message: "Excellent accuracy and control. Expert-path eligibility can be considered if repeated.",
      recommendationLabel: getAdultsRecommendationLabel(scoreResult.recommendation),
      tone: "Mastery"
    };
  }

  if (scoreResult.masteryLevel === "ReadyToAdvance") {
    return {
      title: "Ready for a stronger challenge",
      message: "You are ready for a stronger challenge. Try the next stage or Deep mode.",
      recommendationLabel: getAdultsRecommendationLabel(scoreResult.recommendation),
      tone: "Confident"
    };
  }

  if (scoreResult.masteryLevel === "Stable") {
    return {
      title: "Stable performance",
      message: isCorrect ? itemInsight : "Your performance is stable. Continue this stage or try another category.",
      recommendationLabel: getAdultsRecommendationLabel(scoreResult.recommendation),
      tone: "Confident"
    };
  }

  if (scoreResult.masteryLevel === "Developing") {
    return {
      title: "Building the pattern",
      message: "You are building the pattern. Try the same stage again with light guidance.",
      recommendationLabel: getAdultsRecommendationLabel(scoreResult.recommendation),
      tone: "Practical"
    };
  }

  return {
    title: "Recovery recommended",
    message: "This session showed friction. A lighter Recovery round is recommended.",
    recommendationLabel: getAdultsRecommendationLabel(scoreResult.recommendation),
    tone: "Supportive"
  };
}
