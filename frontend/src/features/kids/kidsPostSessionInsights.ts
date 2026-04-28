import type { KidsGameplayItem } from "./kidsGameplayContent";
import type { KidsScoreResult } from "./kidsScoring";

export type KidsPostSessionInsight = {
  title: string;
  summary: string;
  celebration: string;
  practiceFocus: string;
  nextStep: string;
};

export function createKidsPostSessionInsight(
  item: KidsGameplayItem,
  score: KidsScoreResult,
  isCorrect: boolean
): KidsPostSessionInsight {
  const celebration = isCorrect
    ? "You found the answer with careful thinking."
    : "You practiced and kept learning. That matters.";

  const practiceFocus = isCorrect
    ? `Keep practicing ${item.categoryName.toLowerCase()} with another friendly round.`
    : `Use a small clue and try ${item.categoryName.toLowerCase()} again.`;

  return {
    title: "Session insight",
    summary: `You practiced ${item.categoryName} in ${item.stage}.`,
    celebration,
    practiceFocus,
    nextStep: score.nextStep
  };
}
