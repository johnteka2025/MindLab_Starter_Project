export type PatternAgeLane = "kids" | "adults" | "seniors";

export type PatternDifficultyLevel = 1 | 2 | 3 | 4;

export type PatternPerformanceSample = {
  isCorrect: boolean;
  score?: number;
  hintUsed?: boolean;
};

export type PatternChallenge = {
  lane: PatternAgeLane;
  familyId: "pattern";
  configurationId: string;
  seed: string;
  difficulty: PatternDifficultyLevel;
  patternKind: string;
  sequence: string[];
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
};

type BuildFreshPatternChallengeArgs = {
  lane: PatternAgeLane;
  baseSeed: string;
  difficulty: PatternDifficultyLevel;
  recentConfigurationIds?: string[];
  variationIndex?: number;
};

const KIDS_TOKENS = ["Star", "Moon", "Sun", "Leaf", "Apple", "Ball", "Kite", "Cloud"];
const SENIOR_TOKENS = ["Circle", "Square", "Triangle", "Star", "Leaf", "Cup"];

const MAX_DIFFICULTY: Record<PatternAgeLane, PatternDifficultyLevel> = {
  kids: 3,
  adults: 4,
  seniors: 3
};

function clampDifficulty(
  lane: PatternAgeLane,
  difficulty: number
): PatternDifficultyLevel {
  const bounded = Math.max(1, Math.min(MAX_DIFFICULTY[lane], Math.round(difficulty)));
  return bounded as PatternDifficultyLevel;
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

function chooseDistinctTokens(pool: string[], count: number, rng: () => number): string[] {
  return deterministicShuffle(pool, rng).slice(0, count);
}

function numericOptions(correct: number, rng: () => number, count = 4): string[] {
  const candidates = new Set<number>();
  const offsets = deterministicShuffle([-6, -4, -3, -2, -1, 1, 2, 3, 4, 6], rng);

  for (const offset of offsets) {
    const candidate = correct + offset;
    if (candidate > 0 && candidate !== correct) {
      candidates.add(candidate);
    }
    if (candidates.size >= count - 1) break;
  }

  let fallback = Math.max(1, correct - 1);
  while (candidates.size < count - 1) {
    if (fallback !== correct) candidates.add(fallback);
    fallback += 1;
  }

  return deterministicShuffle(
    [String(correct), ...Array.from(candidates).slice(0, count - 1).map(String)],
    rng
  );
}

function tokenOptions(correct: string, pool: string[], rng: () => number, count: number): string[] {
  const distractors = deterministicShuffle(
    pool.filter((item) => item !== correct),
    rng
  ).slice(0, count - 1);

  return deterministicShuffle([correct, ...distractors], rng);
}

function buildTokenRepeat(
  pool: string[],
  rng: () => number,
  motif: number[],
  shown: number,
  kind: string,
  label: string,
  hint: string,
  insight: string,
  optionCount: number
): Omit<PatternChallenge, "lane" | "familyId" | "configurationId" | "seed" | "difficulty"> {
  const tokens = chooseDistinctTokens(pool, Math.max(...motif) + 1, rng);
  const sequence = Array.from({ length: shown }, (_, index) => tokens[motif[index % motif.length]!]!);
  const correctAnswer = tokens[motif[shown % motif.length]!]!;
  return {
    patternKind: kind,
    sequence,
    prompt: `${label}: ${sequence.join(", ")}, ?. What comes next?`,
    options: tokenOptions(correctAnswer, pool, rng, optionCount),
    correctAnswer,
    hint,
    insight
  };
}

function buildKidsPattern(
  rng: () => number,
  difficulty: PatternDifficultyLevel,
  variant: number
): Omit<PatternChallenge, "lane" | "familyId" | "configurationId" | "seed" | "difficulty"> {
  const variants = difficulty <= 1
    ? [
        { motif: [0, 1], shown: 5, kind: "AB_REPEAT", hint: "The two items take turns." },
        { motif: [0, 0, 1], shown: 5, kind: "AAB_REPEAT", hint: "Find the repeating group of three items." },
        { motif: [0, 0, 1, 1], shown: 6, kind: "AABB_REPEAT", hint: "Look for two of one item, then two of another." }
      ]
    : difficulty === 2
      ? [
          { motif: [0, 0, 1], shown: 5, kind: "AAB_REPEAT", hint: "Spot the two matching items before the third." },
          { motif: [0, 1, 2], shown: 5, kind: "ABC_REPEAT", hint: "Follow the same three-item order." },
          { motif: [0, 0, 1, 1], shown: 6, kind: "AABB_REPEAT", hint: "Look for pairs that repeat in order." }
        ]
      : [
          { motif: [0, 1, 2], shown: 5, kind: "ABC_REPEAT", hint: "Find the three-item cycle." },
          { motif: [0, 0, 1, 2], shown: 6, kind: "AABC_REPEAT", hint: "Notice the double item at the beginning of each group." },
          { motif: [0, 1, 1, 2], shown: 6, kind: "ABBC_REPEAT", hint: "Notice the double item in the middle of each group." }
        ];
  const choice = variants[variant]!;
  return buildTokenRepeat(
    KIDS_TOKENS, rng, choice.motif, choice.shown, choice.kind,
    "Pattern Builder", choice.hint,
    "Pattern Builder practices noticing a repeating rule and predicting the next item.", 3
  );
}

function buildAdultsPattern(
  rng: () => number,
  difficulty: PatternDifficultyLevel,
  variant: number
): Omit<PatternChallenge, "lane" | "familyId" | "configurationId" | "seed" | "difficulty"> {
  const start = 2 + Math.floor(rng() * 7);
  let sequence: number[] = [];
  let correct = 0;
  let patternKind = "";
  let hint = "";

  if (difficulty <= 1 && variant === 0) {
    const step = 2 + Math.floor(rng() * 4);
    sequence = Array.from({ length: 4 }, (_, i) => start + step * i);
    correct = start + step * 4;
    patternKind = "CONSTANT_STEP";
    hint = "Check whether the same number is added each time.";
  } else if (difficulty <= 1 && variant === 1) {
    const step = 2 + Math.floor(rng() * 4);
    const first = 25 + start;
    sequence = Array.from({ length: 4 }, (_, i) => first - step * i);
    correct = first - step * 4;
    patternKind = "CONSTANT_DECREASE";
    hint = "Check whether the same number is subtracted each time.";
  } else if (difficulty <= 1) {
    const first = 1 + Math.floor(rng() * 4);
    sequence = Array.from({ length: 4 }, (_, i) => first * (2 ** i));
    correct = first * 16;
    patternKind = "SIMPLE_DOUBLING";
    hint = "Check whether each number is twice the preceding number.";
  } else if (difficulty === 2 && variant === 0) {
    const a = 2 + Math.floor(rng() * 3);
    const b = a + 2;
    sequence = [start, start + a, start + a + b, start + a + b + a, start + a + b + a + b];
    correct = sequence[4]! + a;
    patternKind = "ALTERNATING_STEPS";
    hint = "Compare changes between values: two step sizes take turns.";
  } else if (difficulty === 2 && variant === 1) {
    const step = 2 + Math.floor(rng() * 3);
    sequence = [start, start + step, start + step * 3, start + step * 6];
    correct = start + step * 10;
    patternKind = "GROWING_MULTIPLE_STEPS";
    hint = "The amount added increases by the same step each time.";
  } else if (difficulty === 2) {
    const add = 1 + Math.floor(rng() * 4);
    sequence = [start];
    for (let i = 0; i < 3; i += 1) sequence.push(sequence[i]! * 2 + add);
    correct = sequence[3]! * 2 + add;
    patternKind = "DOUBLE_PLUS_CONSTANT";
    hint = "Try doubling a value, then adding the same small number.";
  } else if (difficulty === 3 && variant === 0) {
    const step = 2 + Math.floor(rng() * 3);
    sequence = [start];
    let value = start;
    for (let i = 0; i < 4; i += 1) {
      value += step + i;
      sequence.push(value);
    }
    correct = value + step + 4;
    patternKind = "GROWING_STEP";
    hint = "Look at the differences: they increase by one each time.";
  } else if (difficulty === 3 && variant === 1) {
    const step = 1 + Math.floor(rng() * 3);
    sequence = [start];
    let value = start;
    for (let i = 0; i < 4; i += 1) {
      value += step + 2 * i;
      sequence.push(value);
    }
    correct = value + step + 8;
    patternKind = "ODD_GROWING_STEP";
    hint = "Compare the differences: each increase is two larger than the last.";
  } else if (difficulty === 3) {
    sequence = [start, start + 2, (start + 2) * 2, (start + 2) * 2 + 2];
    correct = sequence[3]! * 2;
    patternKind = "ADD_THEN_DOUBLE";
    hint = "Two different operations alternate: add two, then double.";
  } else if (variant === 0) {
    const first = 1 + Math.floor(rng() * 3);
    sequence = [first];
    for (let i = 0; i < 4; i += 1) sequence.push(sequence[i]! * 2 + 1);
    correct = sequence[4]! * 2 + 1;
    patternKind = "DOUBLE_PLUS_ONE";
    hint = "Apply the same transformation: double, then add one.";
  } else if (variant === 1) {
    const first = 2 + Math.floor(rng() * 4);
    sequence = Array.from({ length: 5 }, (_, i) => (first + i) ** 2);
    correct = (first + 5) ** 2;
    patternKind = "SQUARE_NUMBERS";
    hint = "Consider whether these values are consecutive square numbers.";
  } else {
    const first = 2 + Math.floor(rng() * 2);
    sequence = [first];
    for (let i = 0; i < 4; i += 1) sequence.push(sequence[i]! * 3 - 2);
    correct = sequence[4]! * 3 - 2;
    patternKind = "TRIPLE_MINUS_TWO";
    hint = "Multiply the preceding number by three, then subtract two.";
  }

  const correctAnswer = String(correct);
  const sequenceText = sequence.map(String);
  return {
    patternKind, sequence: sequenceText,
    prompt: `Pattern Logic: what comes next — ${sequenceText.join(", ")}, ?`,
    options: numericOptions(correct, rng, 4), correctAnswer, hint,
    insight: "Pattern Logic practices identifying a consistent rule before predicting the next value."
  };
}

function buildSeniorsPattern(
  rng: () => number,
  difficulty: PatternDifficultyLevel,
  variant: number
): Omit<PatternChallenge, "lane" | "familyId" | "configurationId" | "seed" | "difficulty"> {
  if (difficulty <= 1) {
    const choices = [
      { motif: [0, 1], shown: 5, kind: "CALM_ALTERNATION", hint: "Two items take turns." },
      { motif: [0, 0, 1], shown: 5, kind: "CALM_GROUP_OF_THREE", hint: "Look for two matching items, followed by a different item." },
      { motif: [0, 0, 1, 1], shown: 6, kind: "CALM_PAIRS", hint: "Look for one pair followed by another pair." }
    ];
    const choice = choices[variant]!;
    return buildTokenRepeat(
      SENIOR_TOKENS, rng, choice.motif, choice.shown, choice.kind,
      "Pattern Confidence: take your time", choice.hint,
      "Pattern Confidence supports careful prediction without speed pressure.", 4
    );
  }

  const start = 3 + Math.floor(rng() * 6);
  let sequence: number[] = [];
  let correct = 0;
  let patternKind = "";
  let hint = "";

  if (difficulty === 2 && variant === 0) {
    const step = 2 + Math.floor(rng() * 3);
    sequence = Array.from({ length: 4 }, (_, i) => start + i * step);
    correct = start + 4 * step;
    patternKind = "STEADY_STEP";
    hint = "The same amount is added each time.";
  } else if (difficulty === 2 && variant === 1) {
    const step = 2 + Math.floor(rng() * 3);
    const first = start + 18;
    sequence = Array.from({ length: 4 }, (_, i) => first - i * step);
    correct = first - 4 * step;
    patternKind = "STEADY_DECREASE";
    hint = "The same amount is subtracted each time.";
  } else if (difficulty === 2) {
    sequence = [start, start + 1, start + 3, start + 4, start + 6];
    correct = start + 7;
    patternKind = "GENTLE_ALTERNATING_ONE_TWO";
    hint = "The amount added takes turns: one, then two.";
  } else if (variant === 0) {
    sequence = [start, start + 2, start + 5, start + 7];
    correct = start + 10;
    patternKind = "GENTLE_ALTERNATING_STEPS";
    hint = "The amount added takes turns: two, then three.";
  } else if (variant === 1) {
    sequence = [start, start + 1, start + 3, start + 6, start + 10];
    correct = start + 15;
    patternKind = "GENTLE_GROWING_STEP";
    hint = "The amount added grows slowly: one, two, three, four.";
  } else {
    const first = 1 + Math.floor(rng() * 3);
    sequence = [first, first * 2, first * 4, first * 8];
    correct = first * 16;
    patternKind = "GENTLE_DOUBLING";
    hint = "Each value is twice the one before it.";
  }

  const sequenceText = sequence.map(String);
  return {
    patternKind, sequence: sequenceText,
    prompt: `Pattern Confidence: take your time. What comes next — ${sequenceText.join(", ")}, ?`,
    options: numericOptions(correct, rng, 4), correctAnswer: String(correct), hint,
    insight: "Checking one change at a time supports confident prediction without speed pressure."
  };
}

export function getAdaptivePatternDifficulty(
  lane: PatternAgeLane,
  recentPerformance: PatternPerformanceSample[]
): PatternDifficultyLevel {
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

export function buildPatternChallenge(
  lane: PatternAgeLane,
  seed: string,
  difficulty: PatternDifficultyLevel,
  variationIndex?: number
): PatternChallenge {
  const safeDifficulty = clampDifficulty(lane, difficulty);
  const rng = createRng(`${lane}|pattern|${seed}|${safeDifficulty}`);
  const variant = variationIndex === undefined
    ? stableHash(seed) % 3
    : ((Math.trunc(variationIndex) % 3) + 3) % 3;
  const core = lane === "kids"
    ? buildKidsPattern(rng, safeDifficulty, variant)
    : lane === "adults"
      ? buildAdultsPattern(rng, safeDifficulty, variant)
      : buildSeniorsPattern(rng, safeDifficulty, variant);
  const signature = [
    lane,
    safeDifficulty,
    core.patternKind,
    core.sequence.join(">"),
    core.correctAnswer,
    core.options.join(">")
  ].join("|");
  const configurationHash = stableHash(signature)
    .toString(16)
    .toUpperCase()
    .padStart(8, "0");
  const laneCode = lane === "kids" ? "K" : lane === "adults" ? "A" : "S";

  return {
    lane,
    familyId: "pattern",
    configurationId: `PAT-${laneCode}-D${safeDifficulty}-${configurationHash}`,
    seed,
    difficulty: safeDifficulty,
    ...core
  };
}

export function buildFreshPatternChallenge(
  args: BuildFreshPatternChallengeArgs
): PatternChallenge {
  const recentIds = new Set(args.recentConfigurationIds ?? []);
  for (let attempt = 0; attempt < 64; attempt += 1) {
    const candidate = buildPatternChallenge(
      args.lane,
      `${args.baseSeed}|${attempt}`,
      args.difficulty,
      args.variationIndex
    );

    if (!recentIds.has(candidate.configurationId)) {
      return candidate;
    }
  }

  throw new Error("PATTERN_FRESHNESS_EXHAUSTED: no unseen configuration found");
}
