export type SequenceAgeLane = "kids" | "adults" | "seniors";

export type SequenceDifficultyLevel = 1 | 2 | 3 | 4;

export type SequencePerformanceSample = {
  isCorrect: boolean;
  score?: number;
  hintUsed?: boolean;
};

export type SequenceChallenge = {
  lane: SequenceAgeLane;
  familyId: "sequence";
  configurationId: string;
  seed: string;
  difficulty: SequenceDifficultyLevel;
  sequence: string[];
  recallIndex: number;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
};

type BuildFreshSequenceChallengeArgs = {
  lane: SequenceAgeLane;
  baseSeed: string;
  difficulty: SequenceDifficultyLevel;
  recentConfigurationIds?: string[];
};

const TOKEN_POOLS: Record<SequenceAgeLane, string[]> = {
  kids: ["Sun", "Moon", "Star", "Leaf", "Apple", "Ball", "Cup", "Kite", "Cloud", "Boat"],
  adults: ["Amber", "Blue", "Green", "Silver", "Circle", "Triangle", "Square", "Diamond", "North", "East"],
  seniors: ["Garden", "Key", "Lamp", "Book", "Clock", "Chair", "Apple", "Window", "Letter", "Cup"]
};

const MAX_DIFFICULTY: Record<SequenceAgeLane, SequenceDifficultyLevel> = {
  kids: 3,
  adults: 4,
  seniors: 3
};

function clampDifficulty(
  lane: SequenceAgeLane,
  difficulty: number
): SequenceDifficultyLevel {
  const bounded = Math.max(1, Math.min(MAX_DIFFICULTY[lane], Math.round(difficulty)));
  return bounded as SequenceDifficultyLevel;
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

function getSequenceSpan(
  lane: SequenceAgeLane,
  difficulty: SequenceDifficultyLevel
): number {
  if (lane === "kids") return 1 + difficulty;
  if (lane === "adults") return 2 + difficulty;
  return 1 + difficulty;
}

function getOptionCount(lane: SequenceAgeLane): number {
  return lane === "kids" ? 3 : 4;
}

function getPositionLabel(index: number): string {
  const labels = ["first", "second", "third", "fourth", "fifth", "sixth"];
  return labels[index] ?? `position ${index + 1}`;
}

function getPrompt(
  lane: SequenceAgeLane,
  sequence: string[],
  recallIndex: number
): string {
  const joined = sequence.join(", ");
  const position = getPositionLabel(recallIndex);

  if (lane === "kids") {
    return `Sequence Explorer: remember ${joined}. Which item was ${position}?`;
  }

  if (lane === "adults") {
    return `Working Memory: hold this sequence — ${joined}. Which item was ${position}?`;
  }

  return `Guided Recall: take your time and remember ${joined}. Which item was ${position}?`;
}

function getHint(lane: SequenceAgeLane, recallIndex: number): string {
  const position = getPositionLabel(recallIndex);

  if (lane === "kids") {
    return `Say the sequence slowly and listen for the ${position} item.`;
  }

  if (lane === "adults") {
    return `Rehearse the sequence once, then retrieve only the ${position} position.`;
  }

  return `Repeat the sequence gently in the same order and recall the ${position} item.`;
}

function getInsight(lane: SequenceAgeLane): string {
  if (lane === "kids") {
    return "Sequence Explorer practices remembering order while keeping the challenge playful.";
  }

  if (lane === "adults") {
    return "Working Memory combines short-term retention with accurate position recall.";
  }

  return "Guided Recall supports ordered memory practice without adding speed pressure.";
}

export function getAdaptiveSequenceDifficulty(
  lane: SequenceAgeLane,
  recentPerformance: SequencePerformanceSample[]
): SequenceDifficultyLevel {
  const recent = recentPerformance.slice(0, 5);

  if (recent.length === 0) {
    return 1;
  }

  const correctCount = recent.filter((item) => item.isCorrect).length;
  const accuracy = correctCount / recent.length;
  const scored = recent.filter((item) => Number.isFinite(item.score));
  const averageScore = scored.length > 0
    ? scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length
    : accuracy * 100;
  const hintCount = recent.filter((item) => item.hintUsed === true).length;
  const hintRate = hintCount / recent.length;

  if (accuracy < 0.5 || averageScore < 60) {
    return 1;
  }

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

export function buildSequenceChallenge(
  lane: SequenceAgeLane,
  seed: string,
  difficulty: SequenceDifficultyLevel
): SequenceChallenge {
  const safeDifficulty = clampDifficulty(lane, difficulty);
  const rng = createRng(`${lane}|${seed}|${safeDifficulty}`);
  const pool = TOKEN_POOLS[lane];
  const sequence = deterministicShuffle(pool, rng).slice(
    0,
    getSequenceSpan(lane, safeDifficulty)
  );
  const recallIndex = Math.floor(rng() * sequence.length);
  const correctAnswer = sequence[recallIndex]!;
  const distractors = deterministicShuffle(
    pool.filter((item) => item !== correctAnswer),
    rng
  ).slice(0, getOptionCount(lane) - 1);
  const options = deterministicShuffle([correctAnswer, ...distractors], rng);
  const signature = [
    lane,
    safeDifficulty,
    sequence.join(">"),
    recallIndex,
    options.join(">")
  ].join("|");
  const configurationHash = stableHash(signature)
    .toString(16)
    .toUpperCase()
    .padStart(8, "0");
  const laneCode = lane === "kids" ? "K" : lane === "adults" ? "A" : "S";

  return {
    lane,
    familyId: "sequence",
    configurationId: `SEQ-${laneCode}-D${safeDifficulty}-${configurationHash}`,
    seed,
    difficulty: safeDifficulty,
    sequence,
    recallIndex,
    prompt: getPrompt(lane, sequence, recallIndex),
    options,
    correctAnswer,
    hint: getHint(lane, recallIndex),
    insight: getInsight(lane)
  };
}

export function buildFreshSequenceChallenge(
  args: BuildFreshSequenceChallengeArgs
): SequenceChallenge {
  const recentIds = new Set(args.recentConfigurationIds ?? []);
  let candidate = buildSequenceChallenge(
    args.lane,
    `${args.baseSeed}|0`,
    args.difficulty
  );

  for (let attempt = 0; attempt < 32; attempt += 1) {
    candidate = buildSequenceChallenge(
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
