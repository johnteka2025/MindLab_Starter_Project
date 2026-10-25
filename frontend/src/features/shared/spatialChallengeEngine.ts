/** MindLab Family 5: visual/spatial reasoning. No speed penalties. */
export type SpatialLane = "kids" | "adults" | "seniors";
export type SpatialDifficulty = 1 | 2 | 3 | 4;
export type SpatialPerformance = { isCorrect: boolean; score: number; hintUsed?: boolean };
export type SpatialChallenge = {
  familyId: "spatial";
  lane: SpatialLane;
  configurationId: string;
  scenarioKind: string;
  seed: string;
  difficulty: SpatialDifficulty;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
  timed: false;
};
export type FreshSpatialArgs = {
  lane: SpatialLane;
  baseSeed: string;
  difficulty: SpatialDifficulty;
  variationIndex?: number;
  recentConfigurationIds?: string[];
};

function hash(input: string): number {
  let h = 2166136261;
  for (let i = 0; i < input.length; i++) h = Math.imul(h ^ input.charCodeAt(i), 16777619);
  return h >>> 0;
}
function random(seed: string): (max: number) => number {
  let n = hash(seed) || 1;
  return (max) => {
    n ^= n << 13; n ^= n >>> 17; n ^= n << 5;
    return (n >>> 0) % max;
  };
}
function bounded(lane: SpatialLane, level: number): SpatialDifficulty {
  const cap = lane === "adults" ? 4 : 3;
  return Math.max(1, Math.min(cap, Math.trunc(level))) as SpatialDifficulty;
}
export function getAdaptiveSpatialDifficulty(lane: SpatialLane, history: SpatialPerformance[]): SpatialDifficulty {
  const last = history.slice(0, 5);
  if (last.length < 2) return 1;
  const accuracy = last.filter((x) => x.isCorrect).length / last.length;
  const average = last.reduce((n, x) => n + (Number.isFinite(x.score) ? x.score : 0), 0) / last.length;
  const hints = last.filter((x) => x.hintUsed).length;
  if (accuracy < 0.6 || average < 60) return 1;
  if (last.length === 5 && accuracy === 1 && average >= 92 && hints === 0) return bounded(lane, 4);
  if (last.length >= 3 && accuracy >= 0.9 && average >= 85 && hints <= 1) return bounded(lane, 3);
  if (accuracy >= 0.75 && average >= 75 && hints <= 2) return 2;
  return 1;
}

type Point = [number, number];
const arrows = ["↑ Up", "→ Right", "↓ Down", "← Left"] as const;
const steps: Point[] = [[-1,0],[0,1],[1,0],[0,-1]];
function picture(points: {row: number; col: number; symbol: string}[], width = 5): string {
  const cells = Array.from({length: width}, () => Array<string>(width).fill("·"));
  for (const point of points) cells[point.row]![point.col] = point.symbol;
  return cells.map(row => row.join("  ")).join("\n");
}
function renderShape(cells: Point[]): string {
  const grid = Array.from({length: 4}, () => Array<string>(4).fill("·"));
  for (const [r,c] of cells) grid[r]![c] = "■";
  return grid.map(row => row.join(" ")).join("\n");
}
function rotate(cells: Point[]): Point[] { return cells.map(([r,c]) => [c, 3-r]); }
function mirror(cells: Point[]): Point[] { return cells.map(([r,c]) => [r, 3-c]); }
function shape(rng: (max: number) => number, cycle: number): Point[] {
  // Each cycle uses a genuinely different chiral shape (4, 5 or 6 blocks),
  // not a cosmetic ID change. Reflections cannot equal quarter-turn rotations.
  const variants: Point[][] = [
    [[0,0], [1,0], [2,0], [2,1]],
    [[0,0], [1,0], [2,0], [3,0], [3,1]],
    [[0,0], [1,0], [2,0], [3,0], [3,1], [3,2]]
  ];
  let cells: Point[] = variants[cycle % variants.length]!.map(([r,c]) => [r,c]);
  const turns = rng(4);
  for (let i=0;i<turns;i++) cells = rotate(cells);
  return cells;
}
function uniqueOptions(correct: string, candidates: string[], count: number, seed: string): string[] {
  const others = [...new Set(candidates)].filter((x) => x !== correct);
  if (others.length < count-1) throw new Error("SPATIAL_INSUFFICIENT_DISTRACTORS");
  const select = others.slice(0, count-1);
  const options = [correct, ...select];
  const rng = random("order|"+seed);
  for (let i=options.length-1;i>0;i--) {
    const j=rng(i+1);
    [options[i], options[j]]=[options[j]!, options[i]!];
  }
  return options;
}
function puzzle(lane: SpatialLane, seed: string, level: SpatialDifficulty, variationIndex: number) {
  // Keep the accepted six-slot replay cycle while making the cognitive task
  // (not merely its title) genuinely age-specific.
  const kind = ((variationIndex % 6) + 6) % 6;
  const cycle = Math.floor(Math.max(0, variationIndex) / 6);
  const rng = random(`${lane}|${level}|${seed}|${kind}|${cycle}`);
  const directionOptions = [...arrows];
  const pair = (a: number, b: number) => `${arrows[a]}  →  ${arrows[b]}`;
  const twoMoves = (first: number, second: number) => [
    pair(first, second), pair(second, first),
    pair(first, (second + 2) % 4), pair((first + 2) % 4, second)
  ];
  const route = () => {
    const first = rng(4);
    const second = (first + 1 + 2 * rng(2)) % 4;
    const [dr1, dc1] = steps[first]!;
    const [dr2, dc2] = steps[second]!;
    return {
      first, second,
      home: {row: 2, col: 2, symbol: "●"},
      stop: {row: 2 + dr1, col: 2 + dc1, symbol: "◆"},
      goal: {row: 2 + dr1 + dr2, col: 2 + dc1 + dc2, symbol: "★"}
    };
  };

  if (lane === "adults") {
    // Adults reason about nontrivial transformations of a chiral block figure.
    // Its mirrored versions cannot be mistaken for simple rotations.
    const original = shape(rng, cycle);
    const r1 = rotate(original);
    const r2 = rotate(r1);
    const r3 = rotate(r2);
    const m = mirror(original);
    const mr1 = rotate(m);
    const mr2 = rotate(mr1);
    const mr3 = rotate(mr2);
    const transforms = [original, r1, r2, r3, m, mr1, mr2, mr3];
    const target = [r1, m, r2, mr1, r3, mr2][kind]!;
    const instructions = [
      "rotate it 90° clockwise",
      "reflect it across a VERTICAL mirror (swap left and right)",
      "rotate it 180°",
      "reflect it left-to-right, THEN rotate the result 90° clockwise",
      "rotate it 90° counterclockwise",
      "reflect it across a HORIZONTAL mirror (swap top and bottom)"
    ];
    const names = [
      "ADULT_ROTATE_90", "ADULT_VERTICAL_REFLECTION", "ADULT_ROTATE_180",
      "ADULT_REFLECT_THEN_ROTATE", "ADULT_ROTATE_COUNTERCLOCKWISE", "ADULT_HORIZONTAL_REFLECTION"
    ];
    const correct = renderShape(target);
    return {
      scenarioKind: names[kind]!,
      prompt: `Spatial Reasoning: Mentally ${instructions[kind]}. Which diagram is the result?\n\nOriginal:\n${renderShape(original)}`,
      correctAnswer: correct,
      distractors: transforms.map(renderShape).filter((x) => x !== correct),
      hint: kind === 3 ? "Perform the mirror reflection first, then turn the reflected result." :
        "Track the top and left edges through the stated transformation.",
      insight: "Spatial transformations preserve the arrangement of blocks while changing its orientation."
    };
  }

  if (lane === "kids") {
    if (kind === 1) {
      const symbols = [["▲", "●"], ["★", "◆"], ["■", "●"]][cycle % 3]!;
      const [a, b] = symbols;
      const cards = [
        `${a}  ·\n·  ${b}`, `·  ${a}\n${b}  ·`,
        `${b}  ·\n·  ${a}`, `·  ${b}\n${a}  ·`
      ];
      const sample = cards[rng(4)]!;
      return {
        scenarioKind: "KID_MATCH_SHAPE_CARD",
        prompt: `Shape Navigator: Look carefully at this shape card. Which card below matches EXACTLY?\n\nSample:\n${sample}`,
        correctAnswer: sample, distractors: cards.filter(x => x !== sample),
        hint: "Check both shapes and which corner each one occupies.",
        insight: "Matching both shapes and positions uses careful visual comparison."
      };
    }
    if (kind === 2) {
      const r = route();
      const correct = pair(r.first, r.second);
      return {
        scenarioKind: "KID_TREASURE_TRAIL",
        prompt: `Shape Navigator: Start at ●, collect ◆, then find the treasure ★. Which TWO arrows make this trail?\n\n${picture([r.home, r.stop, r.goal])}`,
        correctAnswer: correct, distractors: twoMoves(r.first, r.second).filter(x => x !== correct),
        hint: "Look for the diamond first. Follow its trail to the star.",
        insight: "A simple path can be followed one move at a time."
      };
    }
    if (kind === 3) {
      const labels = ["★ Star", "▲ Triangle", "◆ Diamond", "■ Square"];
      const icons = ["★", "▲", "◆", "■"];
      const positions = [[1,2], [2,3], [3,2], [2,1]];
      // Rotate the four symbols among the neighboring squares each replay.
      const shift = rng(4);
      const points = [{row:2,col:2,symbol:"○"}, ...positions.map(([row,col],i) => ({
        row:row!, col:col!, symbol:icons[(i+shift)%4]!
      }))];
      return {
        scenarioKind: "KID_NEIGHBOR_SHAPE",
        prompt: `Shape Navigator: Which shape is directly to the RIGHT of the circle ○?\n\n${picture(points)}`,
        correctAnswer: labels[(1+shift)%4]!, distractors: labels.filter((_,i) => i !== (1+shift)%4),
        hint: "Find the circle in the middle, then look one space to its right.",
        insight: "Position words such as left and right describe where shapes are."
      };
    }
    if (kind === 5) {
      const corners: Point[] = [[0,0], [0,2], [2,0], [2,2]];
      const names = ["Top-left", "Top-right", "Bottom-left", "Bottom-right"];
      const target = rng(4);
      const [row,col] = corners[target]!;
      return {
        scenarioKind: "KID_FIND_STAR_CORNER",
        prompt: `Shape Navigator: In which CORNER is the treasure star ★?\n\n${picture([{row,col,symbol:"★"}],3)}`,
        correctAnswer: names[target]!, distractors: names.filter((_,i) => i !== target),
        hint: "Look for the star, then decide if it is at the top or bottom and left or right.",
        insight: "Corners combine two position clues."
      };
    }
    const direction = rng(4);
    const distance = kind === 4 ? 2 : 1;
    const [dr,dc] = steps[direction]!;
    const start = {row:2,col:2,symbol:"●"};
    const treasure = {row:2+dr*distance,col:2+dc*distance,symbol:"★"};
    return {
      scenarioKind: kind === 4 ? "KID_TWO_SQUARE_TREASURE" : "KID_ONE_SQUARE_TREASURE",
      prompt: `Shape Navigator: Help the explorer ● reach the treasure ★. Which arrow points in the right direction for ${distance} ${distance === 1 ? "square" : "squares"}?\n\n${picture([start,treasure])}`,
      correctAnswer: arrows[direction]!, distractors: directionOptions.filter((_,i) => i !== direction),
      hint: "Look from the explorer toward the treasure, without turning the map.",
      insight: "Following directions helps us navigate a picture."
    };
  }

  // Seniors: everyday landmarks and routes, with legible static diagrams,
  // familiar destinations, and no time pressure in any difficulty band.
  const suffix = " Take your time; there is no speed penalty.";
  if (kind === 1 || kind === 3 || kind === 5) {
    const r = route();
    const diagram = picture([r.home, r.stop, r.goal]);
    if (kind === 3) return {
      scenarioKind: "SENIOR_NEXT_LANDMARK_DIRECTION",
      prompt: `Everyday Navigation: You are walking from Home ● to the Park ◆ and then the Clinic ★. After you reach the Park, which direction takes you to the Clinic?${suffix}\n\n${diagram}`,
      correctAnswer: arrows[r.second]!, distractors: directionOptions.filter((_,i) => i !== r.second),
      hint: "Start at the diamond for the Park, then look toward the Clinic star.",
      insight: "Using one landmark at a time keeps a journey clear."
    };
    if (kind === 5) {
      const backFirst = (r.second+2)%4;
      const backSecond = (r.first+2)%4;
      const answer = pair(backFirst,backSecond);
      return {
        scenarioKind: "SENIOR_RETURN_HOME_ROUTE",
        prompt: `Everyday Navigation: You are at the Library ★. Return to Home ● by visiting the Park ◆. Which TWO directions should you walk?${suffix}\n\n${diagram}`,
        correctAnswer: answer, distractors: twoMoves(backFirst,backSecond).filter(x=>x!==answer),
        hint: "Walk from the star to the diamond first; then from the diamond to the circle.",
        insight: "A familiar route can be reversed by following its landmarks backward."
      };
    }
    const answer = pair(r.first,r.second);
    return {
      scenarioKind: "SENIOR_PARK_AND_SHOP_ROUTE",
      prompt: `Everyday Navigation: From Home ●, walk to the Park ◆, then to the Shop ★. Which TWO directions follow this route?${suffix}\n\n${diagram}`,
      correctAnswer: answer, distractors: twoMoves(r.first,r.second).filter(x=>x!==answer),
      hint: "Read the first direction to the Park, then the second to the Shop.",
      insight: "Breaking errands into two short steps makes a route easier to follow."
    };
  }
  const direction = rng(4);
  // A later Library challenge changes the actual map distance, not merely the ID.
  // This avoids the confirmed duplicate at senior variation indices 0 and 6.
  const distance = kind === 4 || (kind === 0 && cycle % 2 === 1) ? 2 : 1;
  const [dr,dc] = steps[direction]!;
  const home={row:2,col:2,symbol:"●"};
  const destination={row:2+dr*distance,col:2+dc*distance,symbol:kind===2 ? "◆" : "★"};
  if (kind === 2) {
    const back = (direction+2)%4;
    return {
      scenarioKind: "SENIOR_WALK_HOME_FROM_PHARMACY",
      prompt: `Everyday Navigation: You are at the Pharmacy ◆. Which direction leads back to Home ●?${suffix}\n\n${picture([home,destination])}`,
      correctAnswer: arrows[back]!, distractors: directionOptions.filter((_,i) => i !== back),
      hint: "Begin at the diamond, not the circle. Find Home from there.",
      insight: "Returning home can require reversing the direction you traveled."
    };
  }
  return {
    scenarioKind: kind === 4 ? "SENIOR_BUS_STOP_LOCATION" : "SENIOR_LIBRARY_DIRECTION",
    prompt: `Everyday Navigation: From Home ●, which direction leads to the ${kind === 4 ? "Bus Stop" : "Library"} ★?${suffix}\n\n${picture([home,destination])}`,
    correctAnswer: arrows[direction]!, distractors: directionOptions.filter((_,i) => i !== direction),
    hint: "Find Home first, then look toward the destination landmark.",
    insight: "Visible landmarks help with practical everyday directions."
  };
}
export function buildSpatialChallenge(lane: SpatialLane, seed: string, difficulty: SpatialDifficulty, variationIndex?:number): SpatialChallenge {
  const safeDifficulty=bounded(lane,difficulty);
  const index=variationIndex === undefined ? hash(seed)%6 : variationIndex;
  const item=puzzle(lane,seed,safeDifficulty,index);
  const options=uniqueOptions(item.correctAnswer,item.distractors,4,`${lane}|${seed}|${index}`);
  const signature=[lane,safeDifficulty,item.scenarioKind,item.prompt,item.correctAnswer].join("|");
  const code=lane==="kids"?"K":lane==="adults"?"A":"S";
  return {
    ...item,
    familyId:"spatial",lane,seed,difficulty:safeDifficulty,timed:false,options,
    configurationId:`SPC-${code}-D${safeDifficulty}-${hash(signature).toString(16).toUpperCase().padStart(8,"0")}`
  };
}
export function buildFreshSpatialChallenge(args: FreshSpatialArgs): SpatialChallenge {
  const recent=new Set(args.recentConfigurationIds??[]);
  for (let attempt=0;attempt<64;attempt++) {
    const item=buildSpatialChallenge(args.lane,`${args.baseSeed}|${attempt}`,args.difficulty,args.variationIndex);
    if (!recent.has(item.configurationId)) return item;
  }
  throw new Error("SPATIAL_FRESHNESS_EXHAUSTED");
}
