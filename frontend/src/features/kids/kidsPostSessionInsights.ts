import type { KidsGameplayItem } from "./kidsGameplayContent";
import type { KidsScoreResult } from "./kidsScoring";

export type KidsPostSessionInsight = {
  title: string;
  summary: string;
  celebration: string;
  practiceFocus: string;
  nextStep: string;
  categoryName: string;
  masteryLabel: string;
  exceptionalLevel: string;
  recoverySuggestion: string;
  childSafeProgressNote: string;
};

const categoryPracticeFocus: Record<string, string> = {
  KC1: "Keep noticing colors and details with a short playful round.",
  KC2: "Keep matching shapes and checking features one step at a time.",
  KC3: "Keep listening to story clues and asking why something happened.",
  KC4: "Keep looking for the pattern that repeats.",
  KC5: "Use calm review to practice without pressure.",
  KC6: "Practice remembering the order slowly, then choose the item asked for.",
  KC7: "Look for clues and think about what probably happened.",
  KC8: "Look carefully, ignore distractors, and match the important feature.",
  KC9: "Think about word meaning, object use, and story details.",
  KC10: "Take a calm breath, use the clue, and try the next step kindly."
};

function getCategoryPracticeFocus(item: KidsGameplayItem, isCorrect: boolean): string {
  const baseFocus = categoryPracticeFocus[item.category] ?? `Keep practicing ${item.categoryName.toLowerCase()} with a friendly round.`;

  if (isCorrect) {
    return baseFocus;
  }

  return `${baseFocus} A calm retry is part of learning.`;
}

function getCelebration(isCorrect: boolean, score: KidsScoreResult): string {
  if (!isCorrect) {
    return "You practiced and kept learning. That matters.";
  }

  if (score.exceptionalLevelUnlocked) {
    return `You unlocked ${score.exceptionalLevel} level with careful thinking.`;
  }

  return "You found the answer with careful thinking.";
}

function getChildSafeProgressNote(score: KidsScoreResult, isCorrect: boolean): string {
  if (!isCorrect) {
    return score.recoveryModeSuggestion || "Try Calm Review with a gentle clue.";
  }

  if (score.exceptionalLevel === "Mastery Spark") {
    return "You are ready for a short challenge, with no pressure.";
  }

  if (score.exceptionalLevel === "Solver") {
    return "You can try a stronger thinking round next.";
  }

  if (score.exceptionalLevel === "Builder") {
    return "You can build this skill with one more round.";
  }

  return "Keep growing with another friendly round.";
}

export function createKidsPostSessionInsight(
  item: KidsGameplayItem,
  score: KidsScoreResult,
  isCorrect: boolean
): KidsPostSessionInsight {
  const categoryName = item.categoryName || item.category;
  const celebration = getCelebration(isCorrect, score);
  const practiceFocus = getCategoryPracticeFocus(item, isCorrect);
  const nextStep = score.adaptiveNextStep || score.nextStep;
  const recoverySuggestion = score.recoveryModeSuggestion || "Try a calm next step.";
  const childSafeProgressNote = getChildSafeProgressNote(score, isCorrect);

  return {
    title: "Session insight",
    summary: `You practiced ${categoryName} in ${item.stage}. Mastery: ${score.masteryLabel}. Level: ${score.exceptionalLevel}.`,
    celebration,
    practiceFocus,
    nextStep,
    categoryName,
    masteryLabel: score.masteryLabel,
    exceptionalLevel: score.exceptionalLevel,
    recoverySuggestion,
    childSafeProgressNote
  };
}
