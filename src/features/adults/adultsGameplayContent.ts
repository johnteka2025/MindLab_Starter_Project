export const adultsGameplayItems = [
  {
    certifiedId: "A-AC01-A1-P01",
    category: "AC1",
    categoryName: "Focus and Attention Control",
    stage: "A1",
    sessionProfile: "QuickFocus",
    promptType: "VisualFocus",
    objective: "Selective attention with light distraction control",
    prompt: "Find the only item that matches the target rule.",
    options: ["Target match", "Near distractor", "Shape distractor", "Color distractor"],
    correctAnswer: "Target match",
    answerFormat: "SingleChoice",
    difficulty: "Intro",
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    insight: "Focus on the rule first, then ignore items that only partly match."
  },
  {
    certifiedId: "A-AC03-A1-P02",
    category: "AC3",
    categoryName: "Logic and Pattern Reasoning",
    stage: "A1",
    sessionProfile: "QuickFocus",
    promptType: "PatternLogic",
    objective: "Recognize simple rule patterns and complete sequence",
    prompt: "Choose the next item that completes the pattern.",
    options: ["Next rule match", "Repeated prior item", "Opposite rule", "Unrelated item"],
    correctAnswer: "Next rule match",
    answerFormat: "SingleChoice",
    difficulty: "Intro",
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    insight: "Look for the rule that changes consistently from step to step."
  },
  {
    certifiedId: "A-AC05-A2-P03",
    category: "AC5",
    categoryName: "Decision Making Under Pressure",
    stage: "A2",
    sessionProfile: "Standard",
    promptType: "DecisionTradeoff",
    objective: "Balance accuracy and decision speed with clear constraints",
    prompt: "Select the best option after comparing speed, risk, and accuracy cues.",
    options: ["Balanced option", "Fast but risky", "Accurate but too slow", "Unclear option"],
    correctAnswer: "Balanced option",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OptionalVisible",
    hintPolicy: "LayeredHints",
    insight: "The best choice balances the strongest accuracy signal with manageable timing."
  },
  {
    certifiedId: "A-AC06-A2-P04",
    category: "AC6",
    categoryName: "Language Insight and Interpretation",
    stage: "A2",
    sessionProfile: "Deep",
    promptType: "LanguageInference",
    objective: "Infer meaning from concise adult-focused prompts",
    prompt: "Choose the interpretation best supported by the prompt.",
    options: ["Evidence-based interpretation", "Assumption-heavy interpretation", "Too broad", "Contradicted interpretation"],
    correctAnswer: "Evidence-based interpretation",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    insight: "Choose the answer that is supported directly by the available evidence."
  }
];

export const defaultAdultsGameplayItemId = "A-AC01-A1-P01";

export function getAdultsGameplayItemById(certifiedId) {
  return adultsGameplayItems.find((item) => item.certifiedId === certifiedId) ?? adultsGameplayItems[0];
}

export function getAdultsGameplayItemsForSession(sessionMode) {
  return adultsGameplayItems.filter((item) => item.sessionProfile === sessionMode);
}

export function getDefaultAdultsGameplayItemForSession(sessionMode) {
  const items = getAdultsGameplayItemsForSession(sessionMode);
  return items[0] ?? getAdultsGameplayItemById(defaultAdultsGameplayItemId);
}
