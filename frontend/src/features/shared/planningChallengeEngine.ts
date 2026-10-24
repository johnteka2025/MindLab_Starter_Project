/** MindLab Family 4: deterministic, age-adapted planning and decision making. */
export type PlanningAgeLane = "kids" | "adults" | "seniors";
export type PlanningDifficulty = 1 | 2 | 3 | 4;

export type PlanningPerformance = {
  isCorrect: boolean;
  score: number;
  hintUsed?: boolean;
};

export type PlanningChallenge = {
  lane: PlanningAgeLane;
  familyId: "planning";
  configurationId: string;
  scenarioKind: string;
  seed: string;
  difficulty: PlanningDifficulty;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
  timed: false;
};

export type FreshPlanningArgs = {
  lane: PlanningAgeLane;
  baseSeed: string;
  difficulty: PlanningDifficulty;
  variationIndex?: number;
  recentConfigurationIds?: string[];
};

type Scenario = Pick<PlanningChallenge, "scenarioKind" | "prompt" | "options" | "correctAnswer" | "hint" | "insight">;
type ScenarioBuilder = (nextInt: (min: number, max: number) => number, difficulty: PlanningDifficulty) => Scenario;

function hashString(text: string): number {
  let h = 2166136261;
  for (let i = 0; i < text.length; i++) {
    h = Math.imul(h ^ text.charCodeAt(i), 16777619);
  }
  return h >>> 0;
}

function seededRandom(seed: string): (min: number, max: number) => number {
  let state = hashString(seed) || 1;
  return (min, max) => {
    state ^= state << 13;
    state ^= state >>> 17;
    state ^= state << 5;
    return min + ((state >>> 0) % (max - min + 1));
  };
}

function shuffleOptions(options: string[], seed: string): string[] {
  const nextInt = seededRandom(`choices|${seed}`);
  const result = [...options];
  for (let i = result.length - 1; i > 0; i--) {
    const j = nextInt(0, i);
    [result[i], result[j]] = [result[j]!, result[i]!];
  }
  return result;
}

function scenario(
  scenarioKind: string,
  prompt: string,
  correctAnswer: string,
  distractors: [string, string, string],
  hint: string,
  insight: string
): Scenario {
  return {
    scenarioKind,
    prompt,
    options: [correctAnswer, ...distractors],
    correctAnswer,
    hint,
    insight
  };
}

const kidsBuilders: ScenarioBuilder[] = [
  (n, d) => {
    const toy = ["robot", "kite", "model car"][n(0, 2)];
    return scenario("STEPS_BEFORE_ACTION", `Path Planner: You want to use your new ${toy}. You must put it together before you play. Which plan works?`,
      `Put the ${toy} together, then play with it`,
      [`Play before putting the ${toy} together`, "Put it away before building it", "Skip the instructions and guess every step"],
      "Find the step that must happen first.", "Planning starts with the step that makes the next action possible.");
  },
  (n, d) => {
    const item = ["flower seeds", "bean seeds", "sunflower seeds"][n(0, 2)];
    return scenario("PLANTING_ORDER", `Path Planner: To grow ${item}, you need soil, seeds, and water. Which order makes sense${d >= 3 ? " if you can only water after planting" : ""}?`,
      "Add soil, plant the seeds, then water", ["Water an empty pot, then leave", "Plant seeds on a table, then add soil", "Water first, plant later, skip the soil"],
      "Prepare the place for the seeds before planting.", "Good plans arrange dependent steps in a useful order.");
  },
  (n, d) => {
    const destination = ["park", "library", "playground"][n(0, 2)];
    return scenario("PREPARE_BEFORE_LEAVE", `Path Planner: You are going to the ${destination}. Shoes and your bag are needed before leaving. Which plan is ready?`,
      "Put on shoes, pack the bag, then leave", ["Leave first, find shoes later", "Pack the bag, leave without shoes", "Go out, then return twice to pack"],
      "Check what you need before you go.", "Preparing necessities first saves unnecessary return trips.");
  },
  (n, d) => {
    const fruit = ["apple", "pear", "peach"][n(0, 2)];
    return scenario("FOOD_PREPARATION", `Path Planner: You want to prepare a ${fruit} snack. It needs washing before cutting. What is the best order?`,
      "Wash the fruit, then ask an adult to help cut it", ["Cut the fruit first, wash later", "Serve the fruit without washing", "Put fruit away before preparing it"],
      "Choose the safe preparation step first.", "Safe preparation and correct order are part of good planning.");
  },
  (n, d) => {
    const project = ["paper bridge", "cardboard house", "block tower"][n(0, 2)];
    return scenario("PLAN_THEN_BUILD", `Path Planner: You need to build a ${project} using limited supplies. Which plan avoids wasting materials?`,
      "Sketch a simple design, check supplies, then build", ["Use all supplies before choosing a design", "Build random pieces and throw them away", "Start over without looking at the goal"],
      "Think about the goal before using supplies.", "A small plan reduces rework when materials are limited.");
  },
  (n, d) => {
    const route = ["bridge", "gate", "tunnel"][n(0, 2)];
    return scenario("REMOVE_BLOCKER", `Path Planner: Your toy car needs to cross a ${route}, but the way is blocked. What should you do before trying to cross?`,
      "Clear the obstacle safely, then continue", ["Keep driving into the obstacle", "Forget the destination and circle forever", "Close the path with another obstacle"],
      "Solve the blocker before the next step.", "Planning means identifying and removing obstacles in the correct order.");
  }
];

const adultBuilders: ScenarioBuilder[] = [
  (n, d) => {
    const deadline = n(1, 3);
    return scenario("DEPENDENCY_PLANNING", `Strategic Decisions: A report is due in ${deadline} day${deadline === 1 ? "" : "s"}. The data must be validated before the report is written. Which sequence minimizes rework?`,
      "Validate data, draft the report, then review it", ["Draft final claims before checking data", "Submit first and validate later", "Review an empty report before gathering data"],
      "Order tasks by what each one depends on.", "Validating inputs first reduces avoidable rework.");
  },
  (n, d) => {
    const available = n(5, 8);
    const essential = available - n(1, 2);
    return scenario("CAPACITY_CONSTRAINT", `Strategic Decisions: You have ${available} hours today. A deadline task takes ${essential} hours; an optional task takes 3 hours. Which plan guarantees the deadline task fits?`,
      `Schedule the ${essential}-hour deadline task first and defer the optional task`,
      ["Do the optional task first and assume time is unlimited", "Book both tasks even though total time exceeds capacity", "Wait until the last hour to begin the deadline task"],
      "Compare available hours with the required work.", "Prioritize nondeferrable work when capacity is constrained.");
  },
  (n, d) => {
    const budget = n(8, 12) * 10;
    const essential = budget - 20;
    return scenario("BUDGET_TRADEOFF", `Strategic Decisions: A project has a $${budget} budget. Mandatory materials cost $${essential}, and an optional extra costs $30. What stays within budget and meets requirements?`,
      `Buy the $${essential} mandatory materials and defer the extra`,
      ["Buy both even though they exceed the budget", "Buy only the optional extra", "Avoid all materials and declare the project complete"],
      "Fund requirements before optional upgrades.", "Budget planning separates necessary commitments from discretionary spending.");
  },
  (n, d) => {
    const hours = n(6, 9);
    return scenario("CONTINGENCY_BUFFER", `Strategic Decisions: You have ${hours} hours before delivery. Core work takes ${hours - 2} hours; an uncertain review may take 1 hour. Which schedule protects delivery?`,
      "Start core work now and reserve the remaining time for review", ["Fill all available time with optional work first", "Begin core work after the delivery time", "Ignore the possible review and add unrelated tasks"],
      "Keep a buffer for tasks that may take longer than expected.", "Contingency capacity lowers deadline risk.");
  },
  (n, d) => {
    const duration = n(2, 4);
    return scenario("CRITICAL_DEPENDENCY", `Strategic Decisions: Design must finish before testing. Design takes ${duration} days and testing takes 2 days; a separate 1-day logo task is independent. What should start first to protect the delivery path?`,
      "Begin design immediately so testing can follow", ["Finish the optional logo before beginning design", "Begin testing before any design exists", "Postpone design until the last day"],
      "Find the task that unlocks the next required task.", "Protecting the critical path reduces downstream delay.");
  },
  (n, d) => {
    const clients = n(3, 7);
    return scenario("QUALITY_VS_SPEED", `Strategic Decisions: A team must deliver a verified result to ${clients} clients. A rushed option skips required checks; a staged option completes checks before release. Which plan meets the quality constraint?`,
      "Complete required checks, then release in a controlled sequence", ["Skip checks to report an earlier delivery", "Publish partial results as verified", "Hide the incomplete checks from clients"],
      "Required quality checks are constraints, not optional bonuses.", "A good decision respects delivery and quality requirements together.");
  }
];

const seniorsBuilders: ScenarioBuilder[] = [
  (n, d) => {
    const time = n(9, 11);
    return scenario("ERRAND_OPENING_HOURS", `Everyday Planning: The library opens at ${time}:00 AM. You would like to return a book and buy groceries. Which plan avoids arriving before opening? Take your time.`,
      `Visit the library after ${time}:00 AM, then shop`, ["Arrive at the library before it opens", "Shop, then forget the book return", "Return the book when the library is closed"],
      "Check when a place opens before scheduling a visit.", "A simple timetable prevents unnecessary trips.");
  },
  (n, d) => {
    const day = ["Monday", "Tuesday", "Wednesday"][n(0, 2)];
    return scenario("CALENDAR_REMINDER", `Everyday Planning: You have a meeting on ${day}. You would like a reminder in advance. What is the most dependable plan? Take your time.`,
      `Put the meeting on your calendar with a reminder`, ["Rely only on remembering without a note", "Write the meeting on an unmarked scrap and lose it", "Set a reminder for after the meeting"],
      "Use a reminder that comes before the event.", "Recording plans in a calendar can reduce memory load.");
  },
  (n, d) => {
    const task = ["laundry", "garden watering", "tidying the room"][n(0, 2)];
    return scenario("PREPARE_SUPPLIES", `Everyday Planning: You plan to do ${task} today. Which first step makes the activity easier? Take your time.`,
      "Gather needed supplies before beginning", ["Start, then repeatedly leave to find supplies", "Ignore the items required", "Finish the task before collecting supplies"],
      "Prepare what you need before starting.", "Small preparation steps make everyday tasks simpler.");
  },
  (n, d) => {
    const food = ["milk", "yogurt", "frozen peas"][n(0, 2)];
    return scenario("GROCERY_SEQUENCE", `Everyday Planning: You are buying dry goods and ${food}, which needs to stay cold. Which plan is most practical? Take your time.`,
      `Collect dry goods first, get ${food} near the end, then head home`, ["Choose the cold item first and leave it warm during other errands", "Buy the cold item and stop for unrelated long visits", "Leave all groceries at the store"],
      "Save cold items until you are nearly ready to leave.", "Good errand order helps protect perishable groceries.");
  },
  (n, d) => {
    const stop = ["post office", "pharmacy counter", "community center"][n(0, 2)];
    return scenario("TRAVEL_BUFFER", `Everyday Planning: You need to arrive at the ${stop} by a set time. Which plan allows for travel delays? Take your time.`,
      "Check travel time and leave a little early", ["Leave at the exact arrival time", "Start another long task just before leaving", "Ignore how long the trip will take"],
      "Allow enough travel time plus a small margin.", "A travel buffer reduces stress from unexpected delays.");
  },
  (n, d) => {
    const visitor = ["neighbor", "family member", "friend"][n(0, 2)];
    return scenario("SMALL_TASK_CHECKLIST", `Everyday Planning: A ${visitor} is visiting later. You want to tidy the table and prepare tea before the visit. Which plan helps you remember both? Take your time.`,
      "Write down both tasks and complete them before the visit", ["Do only one task and assume the other is done", "Wait until after the visit to prepare", "Change the plan every minute without checking progress"],
      "Write a short checklist for two related tasks.", "Simple checklists support steady, independent planning.");
  }
];

const builders: Record<PlanningAgeLane, ScenarioBuilder[]> = {
  kids: kidsBuilders,
  adults: adultBuilders,
  seniors: seniorsBuilders
};

const maxDifficulty: Record<PlanningAgeLane, PlanningDifficulty> = {
  kids: 3,
  adults: 4,
  seniors: 3
};

function boundedDifficulty(lane: PlanningAgeLane, value: number): PlanningDifficulty {
  return Math.max(1, Math.min(maxDifficulty[lane], Math.trunc(value))) as PlanningDifficulty;
}

export function getAdaptivePlanningDifficulty(
  lane: PlanningAgeLane,
  samples: PlanningPerformance[]
): PlanningDifficulty {
  const recent = samples.slice(0, 5);
  if (recent.length < 2) return 1;
  const accuracy = recent.filter((entry) => entry.isCorrect).length / recent.length;
  const average = recent.reduce((sum, entry) => sum + (Number.isFinite(entry.score) ? entry.score : 0), 0) / recent.length;
  const hints = recent.filter((entry) => entry.hintUsed === true).length;
  if (accuracy < 0.6 || average < 60) return 1;
  if (recent.length === 5 && accuracy === 1 && average >= 92 && hints === 0) {
    return boundedDifficulty(lane, lane === "adults" ? 4 : 3);
  }
  if (recent.length >= 3 && accuracy >= 0.9 && average >= 85 && hints <= 1) return 3;
  if (accuracy >= 0.75 && average >= 75 && hints <= 2) return 2;
  return 1;
}

export function buildPlanningChallenge(
  lane: PlanningAgeLane,
  seed: string,
  difficulty: PlanningDifficulty,
  variationIndex?: number
): PlanningChallenge {
  const safeDifficulty = boundedDifficulty(lane, difficulty);
  const entries = builders[lane];
  const index = variationIndex === undefined
    ? hashString(seed) % entries.length
    : ((Math.trunc(variationIndex) % entries.length) + entries.length) % entries.length;
  const nextInt = seededRandom(`planning|${lane}|${safeDifficulty}|${seed}`);
  const draft = entries[index]!(nextInt, safeDifficulty);
  // Each adaptive level increases the number of plausible choices: 2, 3, then 4.
  const choiceCount = Math.min(4, safeDifficulty + 1);
  const offered = draft.options.slice(0, choiceCount);
  const options = shuffleOptions(offered, `${seed}|${lane}`);
  if (new Set(options).size !== options.length || !options.includes(draft.correctAnswer)) {
    throw new Error("PLANNING_INVALID_OPTIONS");
  }
  const signature = `${lane}|${safeDifficulty}|${draft.scenarioKind}|${draft.prompt}|${draft.correctAnswer}`;
  const configurationHash = hashString(signature).toString(16).toUpperCase().padStart(8, "0");
  const laneCode = lane === "kids" ? "K" : lane === "adults" ? "A" : "S";
  return {
    ...draft,
    lane,
    familyId: "planning",
    seed,
    difficulty: safeDifficulty,
    options,
    configurationId: `PLN-${laneCode}-D${safeDifficulty}-${configurationHash}`,
    timed: false
  };
}

export function buildFreshPlanningChallenge(args: FreshPlanningArgs): PlanningChallenge {
  const seen = new Set(args.recentConfigurationIds ?? []);
  for (let attempt = 0; attempt < 64; attempt++) {
    const candidate = buildPlanningChallenge(
      args.lane,
      `${args.baseSeed}|${attempt}`,
      args.difficulty,
      args.variationIndex
    );
    if (!seen.has(candidate.configurationId)) return candidate;
  }
  throw new Error("PLANNING_FRESHNESS_EXHAUSTED");
}
