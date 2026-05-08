const http = require("http");
const url = require("url");

const host = process.env.BACKEND_HOST || process.env.HOST || "0.0.0.0";
const port = Number(process.env.BACKEND_PORT || process.env.PORT || 8085);

const dailyChallenge = {
  ok: true,
  id: "daily-adults-strategy-001",
  title: "Strategic Cognitive Challenge",
  mode: "adults",
  ageMode: "adults",
  category: "strategy",
  type: "daily",
  difficulty: "adaptive_adult_progression",
  prompt: "Choose the strongest strategy to complete the focus challenge.",
  question: "Which action best supports focus, memory, and adaptive challenge growth?",
  choices: [
    "Choose strategy",
    "Complete focus challenge",
    "Review memory result",
    "Increase adaptive difficulty"
  ],
  options: [
    "Choose strategy",
    "Complete focus challenge",
    "Review memory result",
    "Increase adaptive difficulty"
  ],
  answer: "Choose strategy",
  correctAnswer: "Choose strategy",
  explanation: "Strategy selection is the first step in the Adults daily readiness flow.",
  hints: [
    "Start with strategy.",
    "Then complete the focus challenge.",
    "Review memory and progress."
  ],
  tags: ["strategy", "focus", "memory", "adaptive challenge", "replayability"],
  steps: [
    "choose strategy",
    "complete focus challenge",
    "review memory result",
    "increase adaptive difficulty",
    "replay for mastery"
  ],
  createdAt: new Date().toISOString()
};

const puzzles = [
  {
    id: "qa-kids-focus-001",
    title: "Kids Focus Foundation",
    category: "focus",
    ageMode: "kids",
    prompt: "Choose the matching pattern.",
    question: "Which choice matches the pattern?",
    choices: ["pattern", "memory", "speed", "noise"],
    options: ["pattern", "memory", "speed", "noise"],
    answer: "pattern",
    correctAnswer: "pattern"
  },
  dailyChallenge,
  {
    id: "qa-seniors-memory-001",
    title: "Seniors Memory Recall",
    category: "memory",
    ageMode: "seniors",
    prompt: "Recall the displayed item.",
    question: "Which item did you see?",
    choices: ["memory", "strategy", "timer", "score"],
    options: ["memory", "strategy", "timer", "score"],
    answer: "memory",
    correctAnswer: "memory"
  }
];

const dailyStatus = {
  ok: true,
  status: "available",
  completed: false,
  todayCompleted: false,
  streak: 0,
  attempts: 0,
  nextAvailable: null,
  challengeId: dailyChallenge.id,
  ageMode: dailyChallenge.ageMode
};

const difficulty = {
  ok: true,
  current: "adaptive_adult_progression",
  difficulty: "adaptive_adult_progression",
  level: "adaptive",
  selected: "adaptive_adult_progression",
  options: [
    "baseline",
    "adaptive_adult_progression",
    "strategy_skill_growth"
  ],
  levels: [
    { id: "baseline", label: "Baseline", value: 1 },
    { id: "adaptive_adult_progression", label: "Adaptive adult progression", value: 2 },
    { id: "strategy_skill_growth", label: "Strategy skill growth", value: 3 }
  ]
};

const progress = {
  ok: true,
  completed: 0,
  streak: 0,
  sessions: [],
  source: "qa-backend",
  ageModes: ["kids", "adults", "seniors"]
};

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
  req.on("data", chunk => {
    body += chunk;
  });
  req.on("end", () => {
    callback(body);
  });
}

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url || "/", true);
  const pathname = parsed.pathname || "/";

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

  if (pathname === "/daily" || pathname === "/api/daily") {
    return sendJson(res, 200, dailyChallenge);
  }

  if (pathname === "/daily/status" || pathname === "/api/daily/status") {
    return sendJson(res, 200, dailyStatus);
  }

  if (pathname === "/difficulty" || pathname === "/api/difficulty") {
    return sendJson(res, 200, difficulty);
  }

  if (pathname === "/puzzles") {
    return sendJson(res, 200, puzzles);
  }

  if (pathname === "/api/puzzles") {
    return sendJson(res, 200, {
      ok: true,
      puzzles,
      items: puzzles,
      count: puzzles.length
    });
  }

  if (pathname === "/progress" || pathname === "/api/progress") {
    return sendJson(res, 200, progress);
  }

  if (pathname === "/solve" || pathname === "/api/solve" || pathname === "/daily/solve" || pathname === "/api/daily/solve") {
    if (req.method === "POST") {
      return readBody(req, () => {
        sendJson(res, 200, {
          ok: true,
          correct: true,
          result: "accepted",
          challengeId: dailyChallenge.id,
          progress
        });
      });
    }

    return sendJson(res, 200, {
      ok: true,
      puzzle: dailyChallenge,
      challenge: dailyChallenge
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
