const http = require("http");
const url = require("url");

const host = process.env.BACKEND_HOST || process.env.HOST || "0.0.0.0";
const port = Number(process.env.BACKEND_PORT || process.env.PORT || 8085);

const puzzles = [
  {
    id: "qa-kids-focus-001",
    title: "Kids Focus Foundation",
    category: "focus",
    ageMode: "kids",
    prompt: "Choose the matching pattern.",
    answer: "pattern"
  },
  {
    id: "qa-adults-strategy-001",
    title: "Adults Strategic Challenge",
    category: "strategy",
    ageMode: "adults",
    prompt: "Select the strongest next move.",
    answer: "strategy"
  },
  {
    id: "qa-seniors-memory-001",
    title: "Seniors Memory Recall",
    category: "memory",
    ageMode: "seniors",
    prompt: "Recall the displayed item.",
    answer: "memory"
  }
];

const progress = {
  ok: true,
  completed: 0,
  streak: 0,
  sessions: [],
  source: "qa-backend"
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

  return sendJson(res, 404, {
    ok: false,
    error: "Not found",
    path: pathname
  });
});

server.listen(port, host, () => {
  console.log(`MindLab backend listening on http://${host}:${port}`);
});
