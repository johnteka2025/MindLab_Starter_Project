const http = require("http");
const url = require("url");

const host = process.env.BACKEND_HOST || process.env.HOST || "0.0.0.0";
const port = Number(process.env.BACKEND_PORT || process.env.PORT || 8085);

function makePuzzle(input) {
  return {
    ok: true,
    id: input.id,
    dailyChallengeId: input.dailyChallengeId || input.id,
    challengeId: input.challengeId || input.dailyChallengeId || input.id,
    title: input.title,
    name: input.title,
    label: input.title,
    mode: input.ageMode,
    ageMode: input.ageMode,
    category: input.category,
    type: input.type || "puzzle",
    daily: input.daily || false,
    isDaily: input.daily || false,
    difficulty: input.difficulty,
    level: input.difficulty,
    prompt: input.prompt,
    question: input.question || input.prompt,
    text: input.prompt,
    choices: input.choices,
    options: input.choices,
    answers: input.choices,
    answer: input.answer,
    correctAnswer: input.answer,
    solution: input.answer,
    explanation: input.explanation,
    hints: input.hints || [],
    tags: input.tags || [],
    steps: input.steps || [],
    metadata: {
      ageMode: input.ageMode,
      category: input.category,
      difficulty: input.difficulty,
      daily: input.daily || false
    }
  };
}

const kidsPuzzle = makePuzzle({
  id: "qa-kids-focus-001",
  title: "Kids Focus Foundation",
  ageMode: "kids",
  category: "focus",
  difficulty: "baseline",
  prompt: "Which choice matches the pattern?",
  choices: ["pattern", "memory", "speed", "noise"],
  answer: "pattern",
  explanation: "Pattern matching supports the Kids focus flow.",
  hints: ["Look for the matching pattern."],
  tags: ["kids", "focus", "pattern"],
  steps: ["look", "match", "choose"]
});

const adultsPuzzle = makePuzzle({
  id: "daily-adults-strategy-001",
  dailyChallengeId: "daily-adults-strategy-001",
  challengeId: "daily-adults-strategy-001",
  title: "Strategic Cognitive Challenge",
  ageMode: "adults",
  category: "strategy",
  type: "daily",
  daily: true,
  difficulty: "adaptive_adult_progression",
  prompt: "Which action best supports focus, memory, and adaptive challenge growth?",
  choices: [
    "Choose strategy",
    "Complete focus challenge",
    "Review memory result",
    "Increase adaptive difficulty"
  ],
  answer: "Choose strategy",
  explanation: "Strategy selection is the first step in the Adults daily readiness flow.",
  hints: ["Start with strategy.", "Then complete the focus challenge.", "Review memory and progress."],
  tags: ["adults", "strategy", "focus", "memory", "adaptive challenge", "replayability"],
  steps: ["choose strategy", "complete focus challenge", "review memory result", "increase adaptive difficulty", "replay for mastery"]
});

const seniorsPuzzle = makePuzzle({
  id: "qa-seniors-memory-001",
  title: "Seniors Memory Recall",
  ageMode: "seniors",
  category: "memory",
  difficulty: "steady_skill_growth",
  prompt: "Which item did you see?",
  choices: ["memory", "strategy", "timer", "score"],
  answer: "memory",
  explanation: "Recall supports the Seniors memory flow.",
  hints: ["Focus on the remembered item."],
  tags: ["seniors", "memory", "recall"],
  steps: ["observe", "recall", "choose"]
});

const puzzles = [kidsPuzzle, adultsPuzzle, seniorsPuzzle];

const dailyPayload = {
  ok: true,
  status: "available",
  completed: false,
  todayCompleted: false,
  streak: 0,
  attempts: 0,
  nextAvailable: null,
  challengeId: adultsPuzzle.id,
  dailyChallengeId: adultsPuzzle.dailyChallengeId,
  ageMode: adultsPuzzle.ageMode,
  puzzle: adultsPuzzle,
  challenge: adultsPuzzle,
  daily: adultsPuzzle,
  selected: adultsPuzzle,
  current: adultsPuzzle,
  item: adultsPuzzle,
  puzzles: [adultsPuzzle],
  items: [adultsPuzzle],
  results: [adultsPuzzle],
  count: 1,
  prompt: adultsPuzzle.prompt,
  question: adultsPuzzle.question,
  choices: adultsPuzzle.choices,
  options: adultsPuzzle.options,
  answer: adultsPuzzle.answer,
  correctAnswer: adultsPuzzle.correctAnswer,
  difficulty: adultsPuzzle.difficulty
};

const dailyStatus = {
  ok: true,
  status: "available",
  completed: false,
  todayCompleted: false,
  streak: 0,
  attempts: 0,
  nextAvailable: null,
  challengeId: adultsPuzzle.id,
  dailyChallengeId: adultsPuzzle.dailyChallengeId,
  ageMode: adultsPuzzle.ageMode,
  puzzles: [adultsPuzzle],
  count: 1
};

const difficultyOptions = ["All", "baseline", "adaptive_adult_progression", "steady_skill_growth", "strategy_skill_growth"];

const difficultyPayload = {
  ok: true,
  current: "adaptive_adult_progression",
  difficulty: "adaptive_adult_progression",
  level: "adaptive",
  selected: "adaptive_adult_progression",
  options: difficultyOptions,
  items: difficultyOptions,
  difficulties: difficultyOptions,
  levels: difficultyOptions.map((value, index) => ({
    id: value,
    label: value,
    value,
    order: index
  }))
};

let solvedCount = 0;

function progressPayload() {
  return {
    ok: true,
    completed: solvedCount,
    solved: solvedCount,
    total: puzzles.length,
    streak: solvedCount > 0 ? 1 : 0,
    completion: Math.round((solvedCount / puzzles.length) * 100),
    percent: Math.round((solvedCount / puzzles.length) * 100),
    sessions: [],
    source: "qa-backend",
    ageModes: ["kids", "adults", "seniors"]
  };
}

function sendJson(res, statusCode, body) {
  const payload = JSON.stringify(body, null, 2);
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Cache-Control": "no-store"
  });
  res.end(payload);
}

function sendOptions(res) {
  res.writeHead(204, {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,Authorization"
  });
  res.end();
}

function readBody(req, callback) {
  let body = "";
  req.on("data", chunk => { body += chunk; });
  req.on("end", () => { callback(body); });
}

function filteredPuzzles(query) {
  let filtered = puzzles.slice();

  if (query.difficulty && query.difficulty !== "All") {
    filtered = filtered.filter(p => p.difficulty === query.difficulty);
  }

  if (query.ageMode) {
    filtered = filtered.filter(p => p.ageMode === query.ageMode);
  }

  if (query.daily === "true") {
    filtered = filtered.filter(p => p.daily === true);
  }

  return filtered;
}

function answerResponse() {
  solvedCount = Math.min(puzzles.length, solvedCount + 1);

  return {
    ok: true,
    correct: true,
    status: "refreshed",
    result: "accepted",
    submitted: true,
    challengeId: adultsPuzzle.id,
    dailyChallengeId: adultsPuzzle.dailyChallengeId,
    puzzle: adultsPuzzle,
    challenge: adultsPuzzle,
    progress: progressPayload()
  };
}

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url || "/", true);
  const pathname = parsed.pathname || "/";
  const query = parsed.query || {};

  if (req.method === "OPTIONS") {
    return sendOptions(res);
  }

  if (pathname === "/health" || pathname === "/api/health") {
    return sendJson(res, 200, {
      ok: true,
      status: "healthy",
      service: "mindlab-backend",
      port,
      timestamp: new Date().toISOString()
    });
  }

  if (
    pathname === "/daily" ||
    pathname === "/api/daily" ||
    pathname === "/daily/challenge" ||
    pathname === "/api/daily/challenge" ||
    pathname === "/daily/today" ||
    pathname === "/api/daily/today"
  ) {
    return sendJson(res, 200, dailyPayload);
  }

  if (pathname === "/daily/puzzles" || pathname === "/api/daily/puzzles") {
    return sendJson(res, 200, [adultsPuzzle]);
  }

  if (pathname === "/daily/status" || pathname === "/api/daily/status") {
    return sendJson(res, 200, dailyStatus);
  }

  if (pathname === "/difficulty" || pathname === "/api/difficulty") {
    return sendJson(res, 200, difficultyPayload);
  }

  if (pathname === "/difficulties" || pathname === "/api/difficulties") {
    return sendJson(res, 200, difficultyOptions);
  }

  if (pathname === "/puzzles") {
    return sendJson(res, 200, filteredPuzzles(query));
  }

  if (pathname === "/api/puzzles") {
    return sendJson(res, 200, {
      ok: true,
      puzzles,
      items: puzzles,
      results: puzzles,
      count: puzzles.length
    });
  }

  if (pathname === "/progress" || pathname === "/api/progress") {
    return sendJson(res, 200, progressPayload());
  }

  if (
    pathname === "/solve" ||
    pathname === "/api/solve" ||
    pathname === "/daily/solve" ||
    pathname === "/api/daily/solve"
  ) {
    if (req.method === "POST") {
      return readBody(req, () => sendJson(res, 200, answerResponse()));
    }

    return sendJson(res, 200, {
      ok: true,
      puzzle: adultsPuzzle,
      challenge: adultsPuzzle,
      selected: adultsPuzzle,
      puzzles,
      items: puzzles,
      options: adultsPuzzle.options
    });
  }

  if (
    pathname === "/daily/submit" ||
    pathname === "/api/daily/submit" ||
    pathname === "/daily/answer" ||
    pathname === "/api/daily/answer"
  ) {
    if (req.method === "POST") {
      return readBody(req, () => sendJson(res, 200, answerResponse()));
    }

    return sendJson(res, 200, {
      ok: true,
      dailyChallengeId: adultsPuzzle.dailyChallengeId,
      puzzle: adultsPuzzle
    });
  }

  return sendJson(res, 404, {
    ok: false,
    error: "Not found",
    path: pathname
  });
});

server.listen(port, host, () => {
  console.log(`MindLab backend listening on http://${host}:${port}`);
});
