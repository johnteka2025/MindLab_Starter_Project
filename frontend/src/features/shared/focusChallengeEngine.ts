export type FocusAgeLane = "kids" | "adults" | "seniors";

export type FocusDifficultyLevel = 1 | 2 | 3 | 4;

export type FocusPerformanceSample = {
  isCorrect: boolean;
  score?: number;
  hintUsed?: boolean;
};

export type FocusChallenge = {
  lane: FocusAgeLane;
  familyId: "focus";
  configurationId: string;
  seed: string;
  difficulty: FocusDifficultyLevel;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
};

type BuildFreshFocusChallengeArgs = {
  lane: FocusAgeLane;
  baseSeed: string;
  difficulty: FocusDifficultyLevel;
  recentConfigurationIds?: string[];
};

type FocusCard = {
  color: string;
  shape: string;
  marker: string;
};

const COLORS = ["Blue", "Green", "Amber", "Silver", "Red", "Purple"];
const SHAPES = ["Circle", "Square", "Triangle", "Star", "Diamond", "Oval"];
const MARKERS = ["1", "2", "3", "4"];

const MAX_DIFFICULTY: Record<FocusAgeLane, FocusDifficultyLevel> = {
  kids: 3,
  adults: 4,
  seniors: 3
};

function clampDifficulty(
  lane: FocusAgeLane,
  difficulty: number
): FocusDifficultyLevel {
  const bounded = Math.max(1, Math.min(MAX_DIFFICULTY[lane], Math.round(difficulty)));
  return bounded as FocusDifficultyLevel;
}

function stableHash(value: string): number {
  let hash = 2166136261;

  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }

  return hash >>> 0;
}

function createRng(seedText: string): () => number {
  let state = stableHash(seedText) || 0x6d2b79f5;

  return () => {
    state += 0x6d2b79f5;
    let value = state;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function deterministicShuffle<T>(items: T[], rng: () => number): T[] {
  const result = [...items];

  for (let index = result.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(rng() * (index + 1));
    [result[index], result[swapIndex]] = [result[swapIndex]!, result[index]!];
  }

  return result;
}

function buildCards(): FocusCard[] {
  const cards: FocusCard[] = [];

  for (const color of COLORS) {
    for (const shape of SHAPES) {
      for (const marker of MARKERS) {
        cards.push({ color, shape, marker });
      }
    }
  }

  return cards;
}

const CARDS = buildCards();

function getOptionCount(lane: FocusAgeLane): number {
  return lane === "kids" ? 3 : 4;
}

function getRuleDimensions(
  lane: FocusAgeLane,
  difficulty: FocusDifficultyLevel
): Array<keyof FocusCard> {
  if (difficulty <= 1) return ["color"];
  if (lane === "adults" && difficulty >= 4) return ["color", "shape", "marker"];
  return ["color", "shape"];
}

function cardLabel(
  lane: FocusAgeLane,
  card: FocusCard,
  dimensions: Array<keyof FocusCard>
): string {
  if (dimensions.includes("marker")) {
    return `${card.color} ${card.shape} ${card.marker}`;
  }

  if (dimensions.includes("shape")) {
    return `${card.color} ${card.shape}`;
  }

  return lane === "kids" ? `${card.color} card` : card.color;
}

function matchesRule(
  card: FocusCard,
  target: FocusCard,
  dimensions: Array<keyof FocusCard>
): boolean {
  return dimensions.every((dimension) => card[dimension] === target[dimension]);
}

function getPrompt(
  lane: FocusAgeLane,
  target: FocusCard,
  dimensions: Array<keyof FocusCard>
): string {
  const colorOnly = dimensions.length === 1;
  const colorAndShape = dimensions.length === 2;

  if (lane === "kids") {
    if (colorOnly) return `Focus Finder: find the ${target.color} card.`;
    return `Focus Finder: find the ${target.color} ${target.shape}.`;
  }

  if (lane === "adults") {
    if (colorOnly) return `Selective Attention: choose the ${target.color} option and ignore the distractors.`;
    if (colorAndShape) {
      return `Selective Attention: choose the option that is both ${target.color} and ${target.shape}.`;
    }
    return `Selective Attention: choose the option that matches all three rules — ${target.color}, ${target.shape}, marker ${target.marker}.`;
  }

  if (colorOnly) return `Focus & Filter: take your time. Choose the ${target.color} card.`;
  return `Focus & Filter: take your time. Choose the option that is both ${target.color} and ${target.shape}.`;
}

function getHint(
  lane: FocusAgeLane,
  target: FocusCard,
  dimensions: Array<keyof FocusCard>
): string {
  if (lane === "kids") {
    return dimensions.length === 1
      ? `Look only for the color ${target.color}.`
      : `Check the color first, then check the shape.`;
  }

  if (lane === "adults") {
    return dimensions.length >= 3
      ? `Check color, shape, and marker separately before choosing.`
      : `Hold the rule steady and reject choices that match only part of it.`;
  }

  return dimensions.length === 1
    ? `Look for the requested color and ignore the other choices.`
    : `Check one detail at a time: first color, then shape.`;
}

function getInsight(lane: FocusAgeLane): string {
  if (lane === "kids") {
    return "Focus Finder practices noticing the important detail while ignoring close choices.";
  }

  if (lane === "adults") {
    return "Selective Attention practices holding a rule steady while rejecting near matches.";
  }

  return "Focus & Filter practices careful selection without adding speed pressure.";
}

export function getAdaptiveFocusDifficulty(
  lane: FocusAgeLane,
  recentPerformance: FocusPerformanceSample[]
): FocusDifficultyLevel {
  const recent = recentPerformance.slice(0, 5);

  if (recent.length === 0) return 1;

  const accuracy = recent.filter((item) => item.isCorrect).length / recent.length;
  const scored = recent.filter((item) => Number.isFinite(item.score));
  const averageScore = scored.length > 0
    ? scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length
    : accuracy * 100;
  const hintRate = recent.filter((item) => item.hintUsed === true).length / recent.length;

  if (accuracy < 0.5 || averageScore < 60) return 1;

  let difficulty = 1;

  if (recent.length >= 2 && accuracy >= 0.75 && averageScore >= 75 && hintRate <= 0.5) {
    difficulty = 2;
  }

  if (recent.length >= 3 && accuracy >= 0.9 && averageScore >= 85 && hintRate <= 0.34) {
    difficulty = 3;
  }

  if (
    lane === "adults" &&
    recent.length >= 5 &&
    accuracy === 1 &&
    averageScore >= 92 &&
    hintRate === 0
  ) {
    difficulty = 4;
  }

  return clampDifficulty(lane, difficulty);
}

export function buildFocusChallenge(
  lane: FocusAgeLane,
  seed: string,
  difficulty: FocusDifficultyLevel
): FocusChallenge {
  const safeDifficulty = clampDifficulty(lane, difficulty);
  const rng = createRng(`${lane}|focus|${seed}|${safeDifficulty}`);
  const dimensions = getRuleDimensions(lane, safeDifficulty);
  const target = CARDS[Math.floor(rng() * CARDS.length)]!;
  const correctAnswer = cardLabel(lane, target, dimensions);
  const distractorCards = deterministicShuffle(
    CARDS.filter((card) => !matchesRule(card, target, dimensions)),
    rng
  );
  const distractors: string[] = [];

  for (const card of distractorCards) {
    const label = cardLabel(lane, card, dimensions);
    if (label !== correctAnswer && !distractors.includes(label)) {
      distractors.push(label);
    }
    if (distractors.length >= getOptionCount(lane) - 1) break;
  }

  const options = deterministicShuffle([correctAnswer, ...distractors], rng);
  const signature = [
    lane,
    safeDifficulty,
    dimensions.join(">"),
    correctAnswer,
    options.join(">")
  ].join("|");
  const configurationHash = stableHash(signature)
    .toString(16)
    .toUpperCase()
    .padStart(8, "0");
  const laneCode = lane === "kids" ? "K" : lane === "adults" ? "A" : "S";

  return {
    lane,
    familyId: "focus",
    configurationId: `FOC-${laneCode}-D${safeDifficulty}-${configurationHash}`,
    seed,
    difficulty: safeDifficulty,
    prompt: getPrompt(lane, target, dimensions),
    options,
    correctAnswer,
    hint: getHint(lane, target, dimensions),
    insight: getInsight(lane)
  };
}

export function buildFreshFocusChallenge(
  args: BuildFreshFocusChallengeArgs
): FocusChallenge {
  const recentIds = new Set(args.recentConfigurationIds ?? []);
  let candidate = buildFocusChallenge(
    args.lane,
    `${args.baseSeed}|0`,
    args.difficulty
  );

  for (let attempt = 0; attempt < 32; attempt += 1) {
    candidate = buildFocusChallenge(
      args.lane,
      `${args.baseSeed}|${attempt}`,
      args.difficulty
    );

    if (!recentIds.has(candidate.configurationId)) {
      return candidate;
    }
  }

  return candidate;
}
