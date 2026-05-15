const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = Number(process.env.PORT || 8085);
const DATA_DIR = path.join(__dirname, "data");

const sessionsPath = path.join(DATA_DIR, "sessions.json");
const answersPath = path.join(DATA_DIR, "answers.json");
const scoresPath = path.join(DATA_DIR, "scores.json");
const progressPath = path.join(DATA_DIR, "progress.json");

const puzzles = {
  Kids: [
    { id: "kids-1", prompt: "Which shape has three sides?", choices: ["Circle", "Triangle", "Square"], answer: "Triangle" },
    { id: "kids-2", prompt: "What number comes after 4?", choices: ["3", "5", "8"], answer: "5" },
    { id: "kids-3", prompt: "Which word rhymes with cat?", choices: ["Hat", "Dog", "Sun"], answer: "Hat" }
  ],
  Adults: [
    { id: "adults-1", prompt: "Which option best completes the pattern: 2, 4, 8, 16, ?", choices: ["18", "24", "32"], answer: "32" },
    { id: "adults-2", prompt: "A project needs prioritization. What should be checked first?", choices: ["Risk", "Color", "Font"], answer: "Risk" },
    { id: "adults-3", prompt: "Which decision is strongest?", choices: ["Evidence-based", "Random", "Delayed"], answer: "Evidence-based" }
  ],
  Seniors: [
    { id: "seniors-1", prompt: "Which item is usually used to tell time?", choices: ["Clock", "Plate", "Chair"], answer: "Clock" },
    { id: "seniors-2", prompt: "Which action helps confirm safety before crossing?", choices: ["Look both ways", "Close eyes", "Run fast"], answer: "Look both ways" },
    { id: "seniors-3", prompt: "Which number is larger?", choices: ["12", "7", "3"], answer: "12" }
  ]
};

function ensureDataDir() {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

function readJsonFile(filePath, fallback) {
  try {
    if (!fs.existsSync(filePath)) return fallback;
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return fallback;
  }
}

function writeJsonFile(filePath, value) {
  ensureDataDir();
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2), "utf8");
}

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload);

  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type"
  });

  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = "";

    req.on("data", chunk => {
      raw += chunk;

      if (raw.length > 1000000) {
        reject(new Error("Request body too large"));
        req.destroy();
      }
    });

    req.on("end", () => {
      if (!raw.trim()) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch {
        resolve({});
      }
    });

    req.on("error", reject);
  });
}

function normalizeAgeCategory(value) {
  const text = String(value || "Kids").trim().toLowerCase();

  if (text === "kid" || text === "kids" || text === "child" || text === "children") return "Kids";
  if (text === "adult" || text === "adults") return "Adults";
  if (text === "senior" || text === "seniors" || text === "older adult" || text === "older adults") return "Seniors";

  return "Kids";
}

function getQuestion(ageCategory, index) {
  const list = puzzles[ageCategory] || puzzles.Kids;
  const safeIndex = Math.max(0, Math.min(Number(index || 0), list.length - 1));
  return list[safeIndex];
}

function publicQuestion(question) {
  if (!question) return null;

  return {
    id: question.id,
    prompt: question.prompt,
    choices: question.choices
  };
}

function createSession(ageCategory) {
  const sessions = readJsonFile(sessionsPath, []);
  const normalizedAge = normalizeAgeCategory(ageCategory);

  const session = {
    id: "session-" + Date.now() + "-" + Math.random().toString(36).slice(2, 8),
    ageCategory: normalizedAge,
    currentIndex: 0,
    score: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  sessions.push(session);
  writeJsonFile(sessionsPath, sessions);

  return session;
}

const server = http.createServer(async (req, res) => {
  const requestUrl = new URL(req.url, `http://${req.headers.host || "localhost:8085"}`);
  const pathname = requestUrl.pathname;

  if (req.method === "OPTIONS") {
    res.writeHead(204, {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    });
    res.end();
    return;
  }

  try {
    if (req.method === "GET" && (pathname === "/" || pathname === "/health" || pathname === "/api/health")) {
      sendJson(res, 200, {
        ok: true,
        service: "mindlab-backend",
        port: PORT,
        ageCategories: ["Kids", "Adults", "Seniors"]
      });
      return;
    }

    if (req.method === "GET" && (pathname === "/api/age-categories" || pathname === "/api/categories")) {
      sendJson(res, 200, {
        ok: true,
        ageCategories: ["Kids", "Adults", "Seniors"],
        categories: ["Kids", "Adults", "Seniors"]
      });
      return;
    }

    if (req.method === "GET" && (pathname === "/api/questions" || pathname === "/api/puzzles")) {
      const ageCategory = normalizeAgeCategory(requestUrl.searchParams.get("ageCategory"));

      sendJson(res, 200, {
        ok: true,
        ageCategory,
        questions: (puzzles[ageCategory] || puzzles.Kids).map(publicQuestion),
        puzzles: (puzzles[ageCategory] || puzzles.Kids).map(publicQuestion)
      });
      return;
    }

    if (req.method === "POST" && (pathname === "/api/sessions" || pathname === "/api/session")) {
      const body = await readBody(req);
      const session = createSession(body.ageCategory || body.category || body.age || "Kids");
      const question = publicQuestion(getQuestion(session.ageCategory, 0));

      sendJson(res, 201, {
        ok: true,
        sessionId: session.id,
        id: session.id,
        session,
        ageCategory: session.ageCategory,
        question,
        currentQuestion: question
      });
      return;
    }

    if (req.method === "GET" && pathname.startsWith("/api/sessions/")) {
      const sessionId = pathname.split("/").filter(Boolean).pop();
      const sessions = readJsonFile(sessionsPath, []);
      const session = sessions.find(item => item.id === sessionId);

      if (!session) {
        sendJson(res, 404, { ok: false, error: "Session not found", sessionId });
        return;
      }

      const question = publicQuestion(getQuestion(session.ageCategory, session.currentIndex));

      sendJson(res, 200, {
        ok: true,
        session,
        sessionId: session.id,
        question,
        currentQuestion: question
      });
      return;
    }

    if (req.method === "POST" && (pathname === "/api/answers" || pathname === "/api/answer" || pathname === "/api/submit")) {
      const body = await readBody(req);
      const sessions = readJsonFile(sessionsPath, []);
      const answers = readJsonFile(answersPath, []);
      const scores = readJsonFile(scoresPath, []);

      const session = sessions.find(item => item.id === body.sessionId) || null;
      const ageCategory = normalizeAgeCategory(body.ageCategory || (session && session.ageCategory) || "Kids");
      const currentIndex = session ? Number(session.currentIndex || 0) : 0;
      const question = getQuestion(ageCategory, currentIndex);
      const submitted = String(body.answer || body.choice || body.value || "").trim();
      const correct = question ? submitted.toLowerCase() === String(question.answer).toLowerCase() : false;

      answers.push({
        id: "answer-" + Date.now() + "-" + Math.random().toString(36).slice(2, 8),
        sessionId: body.sessionId || null,
        ageCategory,
        questionId: body.questionId || (question && question.id) || null,
        answer: submitted,
        correct,
        createdAt: new Date().toISOString()
      });

      if (session) {
        session.currentIndex = currentIndex + 1;
        if (correct) session.score = Number(session.score || 0) + 1;
        session.updatedAt = new Date().toISOString();
      }

      scores.push({
        sessionId: body.sessionId || null,
        ageCategory,
        correct,
        createdAt: new Date().toISOString()
      });

      writeJsonFile(answersPath, answers);
      writeJsonFile(scoresPath, scores);
      writeJsonFile(sessionsPath, sessions);

      const nextQuestion = session ? publicQuestion(getQuestion(ageCategory, session.currentIndex)) : null;

      sendJson(res, 200, {
        ok: true,
        correct,
        session,
        nextQuestion,
        question: nextQuestion
      });
      return;
    }

    if (req.method === "GET" && pathname === "/api/progress") {
      const progress = readJsonFile(progressPath, {});
      sendJson(res, 200, { ok: true, progress });
      return;
    }

    if (req.method === "POST" && pathname === "/api/progress") {
      const body = await readBody(req);

      writeJsonFile(progressPath, {
        ...body,
        updatedAt: new Date().toISOString()
      });

      sendJson(res, 200, { ok: true });
      return;
    }

    sendJson(res, 404, {
      ok: false,
      error: "Not found",
      path: pathname
    });
  } catch (error) {
    sendJson(res, 500, {
      ok: false,
      error: error.message || "Internal server error"
    });
  }
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`MindLab backend listening on http://0.0.0.0:${PORT}`);
});
