import type { AdultsSessionModeId } from "./adultsSessionModes";

export type AdultsGameplayItem = {
  certifiedId: string;
  category: string;
  categoryName: string;
  stage: string;
  sessionProfile: AdultsSessionModeId;
  promptType: string;
  objective: string;
  prompt: string;
  options: string[];
  correctAnswer: string;
  answerFormat: "SingleChoice";
  difficulty: string;
  timerPolicy: string;
  hintPolicy: string;
  hint: string;
  insight: string;
};

export const adultsGameplayItems: AdultsGameplayItem[] = [
  {
    certifiedId: "A-AC01-A1-P01",
    category: "AC1",
    categoryName: "Focus and Attention Control",
    stage: "A1",
    sessionProfile: "QuickFocus",
    promptType: "RuleFilter",
    objective: "Apply two conditions while ignoring near matches",
    prompt: "A review queue should flag only requests that are both urgent and missing approval. Which request should be flagged?",
    options: [
      "Urgent, approval missing",
      "Urgent, approval present",
      "Routine, approval missing",
      "Routine, approval present"
    ],
    correctAnswer: "Urgent, approval missing",
    answerFormat: "SingleChoice",
    difficulty: "Intro",
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    hint: "Both conditions must be true at the same time.",
    insight: "Selective attention improves when the rule is held constant and near matches are rejected."
  },
  {
    certifiedId: "A-AC03-A1-P02",
    category: "AC3",
    categoryName: "Logic and Pattern Reasoning",
    stage: "A1",
    sessionProfile: "QuickFocus",
    promptType: "PatternLogic",
    objective: "Infer a numerical transformation pattern",
    prompt: "What number comes next: 2, 5, 11, 23, ?",
    options: ["35", "46", "47", "48"],
    correctAnswer: "47",
    answerFormat: "SingleChoice",
    difficulty: "Intro",
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    hint: "Each step doubles the prior value and then adds one.",
    insight: "A consistent transform can be tested across every transition before choosing the next value."
  },
  {
    certifiedId: "A-AC02-A1-P05",
    category: "AC2",
    categoryName: "Working Memory",
    stage: "A1",
    sessionProfile: "QuickFocus",
    promptType: "WorkingMemory",
    objective: "Hold a short rule set and apply it once",
    prompt: "Remember: amber = 4, blue = 7, green = 2. What is blue minus green?",
    options: ["2", "3", "5", "9"],
    correctAnswer: "5",
    answerFormat: "SingleChoice",
    difficulty: "Intro",
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    hint: "Recall the values assigned to blue and green before subtracting.",
    insight: "Working memory combines short-term retention with a simple operation on the retained information."
  },
  {
    certifiedId: "A-AC05-A2-P03",
    category: "AC5",
    categoryName: "Decision Making Under Pressure",
    stage: "A2",
    sessionProfile: "Standard",
    promptType: "DecisionTradeoff",
    objective: "Balance risk, timing, and evidence quality",
    prompt: "A deadline is tomorrow. Option A is fast but has an unresolved safety concern. Option B takes four extra hours and has verified controls. Option C is fastest but has not been reviewed. Which is the strongest choice?",
    options: [
      "Option A because it is almost ready",
      "Option B because the controls are verified",
      "Option C because speed matters most",
      "Choose randomly to avoid delay"
    ],
    correctAnswer: "Option B because the controls are verified",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OptionalVisible",
    hintPolicy: "LayeredHints",
    hint: "Prefer the option that satisfies the deadline without accepting an unresolved critical risk.",
    insight: "Strong decisions balance constraints without allowing speed to override a material risk."
  },
  {
    certifiedId: "A-AC04-A2-P06",
    category: "AC4",
    categoryName: "Planning and Sequencing",
    stage: "A2",
    sessionProfile: "Standard",
    promptType: "DependencyPlanning",
    objective: "Respect dependencies before optimizing sequence",
    prompt: "You must publish a report. Data validation must finish before analysis, and analysis must finish before final review. Which sequence is valid?",
    options: [
      "Final review -> analysis -> validation",
      "Analysis -> validation -> final review",
      "Validation -> analysis -> final review",
      "Validation -> final review -> analysis"
    ],
    correctAnswer: "Validation -> analysis -> final review",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OptionalVisible",
    hintPolicy: "LayeredHints",
    hint: "Place each prerequisite before the task that depends on it.",
    insight: "Planning quality improves when dependency constraints are satisfied before speed or convenience is optimized."
  },
  {
    certifiedId: "A-AC07-A2-P07",
    category: "AC7",
    categoryName: "Quantitative Reasoning",
    stage: "A2",
    sessionProfile: "Standard",
    promptType: "PercentChange",
    objective: "Reason about sequential percentage changes",
    prompt: "A value falls by 20%, then rises by 25% from the reduced value. Compared with the starting value, where does it end?",
    options: ["5% lower", "Back at the starting value", "5% higher", "20% higher"],
    correctAnswer: "Back at the starting value",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OptionalVisible",
    hintPolicy: "LayeredHints",
    hint: "Try a starting value of 100 and apply each percentage in sequence.",
    insight: "Sequential percentages act on different bases, so applying them step by step prevents intuition errors."
  },
  {
    certifiedId: "A-AC06-A2-P04",
    category: "AC6",
    categoryName: "Language Insight and Interpretation",
    stage: "A2",
    sessionProfile: "Deep",
    promptType: "LanguageInference",
    objective: "Separate direct evidence from assumptions",
    prompt: "A pilot reduced processing time in two teams, but error rates were not measured. Which conclusion is best supported?",
    options: [
      "The pilot improved speed in the two teams",
      "The pilot improved quality everywhere",
      "The pilot should replace every current process",
      "The pilot eliminated errors"
    ],
    correctAnswer: "The pilot improved speed in the two teams",
    answerFormat: "SingleChoice",
    difficulty: "Moderate",
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    hint: "Choose only what the stated measurements directly establish.",
    insight: "Evidence-based interpretation limits the conclusion to the population and outcomes actually measured."
  },
  {
    certifiedId: "A-AC03-A3-P08",
    category: "AC3",
    categoryName: "Logic and Pattern Reasoning",
    stage: "A3",
    sessionProfile: "Deep",
    promptType: "ConstraintLogic",
    objective: "Combine multiple logical constraints",
    prompt: "Three tasks X, Y, and Z must be scheduled. X must occur before Y. Z cannot be first. Which order is valid?",
    options: ["Z, X, Y", "Y, X, Z", "X, Z, Y", "Y, Z, X"],
    correctAnswer: "X, Z, Y",
    answerFormat: "SingleChoice",
    difficulty: "Advanced",
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    hint: "Eliminate any order that starts with Z or places Y before X.",
    insight: "Constraint reasoning becomes easier when invalid possibilities are removed one condition at a time."
  },
  {
    certifiedId: "A-AC04-A3-P09",
    category: "AC4",
    categoryName: "Strategic Planning",
    stage: "A3",
    sessionProfile: "Deep",
    promptType: "ContingencyPlanning",
    objective: "Select a plan that preserves options under uncertainty",
    prompt: "A project depends on a supplier with uncertain delivery. Which plan best reduces schedule risk without unnecessary cost?",
    options: [
      "Ignore the uncertainty until the due date",
      "Order from two suppliers in full immediately",
      "Set an early confirmation checkpoint and prepare a limited backup source",
      "Delay all project work until delivery is certain"
    ],
    correctAnswer: "Set an early confirmation checkpoint and prepare a limited backup source",
    answerFormat: "SingleChoice",
    difficulty: "Advanced",
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    hint: "Look for a plan that creates an early warning and a proportionate fallback.",
    insight: "Good contingency planning reduces exposure while preserving flexibility and controlling unnecessary cost."
  },
  {
    certifiedId: "A-AC01-A1-P10",
    category: "AC1",
    categoryName: "Calm Attention Reset",
    stage: "A1",
    sessionProfile: "Recovery",
    promptType: "SimpleFilter",
    objective: "Rebuild focus with one clear condition",
    prompt: "Choose the item that is a time measurement.",
    options: ["12 minutes", "12 meters", "12 dollars", "12 kilograms"],
    correctAnswer: "12 minutes",
    answerFormat: "SingleChoice",
    difficulty: "Recovery",
    timerPolicy: "Off",
    hintPolicy: "SupportiveStepwise",
    hint: "Look for the unit used to measure duration.",
    insight: "A low-pressure reset can restore attention by using one clear rule at a time."
  },
  {
    certifiedId: "A-AC03-A1-P11",
    category: "AC3",
    categoryName: "Calm Pattern Review",
    stage: "A1",
    sessionProfile: "Recovery",
    promptType: "SimpleSequence",
    objective: "Practice a familiar progression without time pressure",
    prompt: "What comes next: 4, 8, 12, 16, ?",
    options: ["18", "20", "22", "24"],
    correctAnswer: "20",
    answerFormat: "SingleChoice",
    difficulty: "Recovery",
    timerPolicy: "Off",
    hintPolicy: "SupportiveStepwise",
    hint: "The same amount is added each time.",
    insight: "Recognizing a simple repeated change can rebuild confidence before returning to harder patterns."
  },
  {
    certifiedId: "A-AC04-A1-P12",
    category: "AC4",
    categoryName: "Calm Planning Review",
    stage: "A1",
    sessionProfile: "Recovery",
    promptType: "EverydaySequence",
    objective: "Use an obvious dependency in a practical sequence",
    prompt: "You need to send a corrected document. What should happen first?",
    options: [
      "Send it before making the correction",
      "Make and verify the correction",
      "Delete the document",
      "Wait without reviewing it"
    ],
    correctAnswer: "Make and verify the correction",
    answerFormat: "SingleChoice",
    difficulty: "Recovery",
    timerPolicy: "Off",
    hintPolicy: "SupportiveStepwise",
    hint: "Complete and verify the required change before sending the file.",
    insight: "Calm planning starts by completing the prerequisite before the final action."
  }
];

export const defaultAdultsGameplayItemId = "A-AC01-A1-P01";

export function getAdultsGameplayItemById(certifiedId: string): AdultsGameplayItem {
  return adultsGameplayItems.find((item) => item.certifiedId === certifiedId) ?? adultsGameplayItems[0];
}

export function getAdultsGameplayItemsForSession(sessionMode: string): AdultsGameplayItem[] {
  return adultsGameplayItems.filter((item) => item.sessionProfile === sessionMode);
}

export function getDefaultAdultsGameplayItemForSession(sessionMode: string): AdultsGameplayItem {
  const items = getAdultsGameplayItemsForSession(sessionMode);
  return items[0] ?? getAdultsGameplayItemById(defaultAdultsGameplayItemId);
}
