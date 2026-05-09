"use strict";

const http = require("http");
const { URL } = require("url");
const { productionApiContract } = require("./production-api-contract.cjs");
const { loadSeedPuzzleContent } = require("./production-content-loader.cjs");

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8",
    "content-length": Buffer.byteLength(body),
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "GET,POST,OPTIONS",
    "access-control-allow-headers": "content-type"
  });
  res.end(body);
}

function readRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1000000) {
        reject(new Error("REQUEST_BODY_TOO_LARGE"));
      }
    });
    req.on("end", () => {
      if (!body) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(body));
      } catch {
        reject(new Error("INVALID_JSON_BODY"));
      }
    });
    req.on("error", reject);
  });
}

function normalizePath(req) {
  const parsed = new URL(req.url, "http://127.0.0.1");
  return parsed.pathname.replace(/\/+$/, "") || "/";
}

function createInMemoryState() {
  return {
    sessions: [],
    answers: [],
    scores: [],
    progress: {}
  };
}

function buildProductionResponse(req, state) {
  const method = req.method.toUpperCase();
  const pathName = normalizePath(req);
  const seedData = loadSeedPuzzleContent();
  const puzzles = seedData.puzzles;

  if (method === "OPTIONS") {
    return { statusCode: 204, payload: null };
  }

  if (method === "GET" && pathName === productionApiContract.routes.health) {
    return {
      statusCode: 200,
      payload: {
        ok: true,
        service: "mindlab-production-backend",
        contractVersion: productionApiContract.version,
        puzzleCount: puzzles.length
      }
    };
  }

  if (method === "GET" && pathName === productionApiContract.routes.puzzles) {
    return {
      statusCode: 200,
      payload: {
        ok: true,
        count: puzzles.length,
        puzzles
      }
    };
  }

  if (method === "GET" && pathName === productionApiContract.routes.seedPuzzles) {
    return {
      statusCode: 200,
      payload: {
        ok: true,
        seed: seedData
      }
    };
  }

  if (method === "GET" && pathName.startsWith("/api/puzzles/")) {
    const id = decodeURIComponent(pathName.replace("/api/puzzles/", ""));
    const puzzle = puzzles.find((item) => String(item.id) === id);

    if (!puzzle) {
      return {
        statusCode: 404,
        payload: {
          ok: false,
          error: "PUZZLE_NOT_FOUND",
          id
        }
      };
    }

    return {
      statusCode: 200,
      payload: {
        ok: true,
        puzzle
      }
    };
  }

  if (method === "GET" && pathName === productionApiContract.routes.progress) {
    return {
      statusCode: 200,
      payload: {
        ok: true,
        progress: state.progress
      }
    };
  }

  return {
    statusCode: 404,
    payload: {
      ok: false,
      error: "ROUTE_NOT_FOUND",
      method,
      path: pathName
    }
  };
}

function createProductionServer(options = {}) {
  const state = options.state || createInMemoryState();

  return http.createServer(async (req, res) => {
    try {
      const method = req.method.toUpperCase();
      const pathName = normalizePath(req);

      if (method === "POST" && pathName === productionApiContract.routes.sessions) {
        const body = await readRequestBody(req);
        const session = {
          id: body.id || `session-${Date.now()}`,
          userId: body.userId || "anonymous",
          ageCategory: body.ageCategory || "kids",
          startedAt: new Date().toISOString(),
          completedAt: null,
          status: "active"
        };
        state.sessions.push(session);
        sendJson(res, 201, { ok: true, session });
        return;
      }

      if (method === "POST" && pathName === productionApiContract.routes.answers) {
        const body = await readRequestBody(req);
        const answer = {
          id: body.id || `answer-${Date.now()}`,
          sessionId: body.sessionId || null,
          puzzleId: body.puzzleId || null,
          selectedAnswer: body.selectedAnswer,
          isCorrect: Boolean(body.isCorrect),
          answeredAt: new Date().toISOString()
        };
        state.answers.push(answer);
        sendJson(res, 201, { ok: true, answer });
        return;
      }

      const result = buildProductionResponse(req, state);

      if (result.statusCode === 204) {
        res.writeHead(204, {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "GET,POST,OPTIONS",
          "access-control-allow-headers": "content-type"
        });
        res.end();
        return;
      }

      sendJson(res, result.statusCode, result.payload);
    } catch (error) {
      sendJson(res, 500, {
        ok: false,
        error: "PRODUCTION_BACKEND_ERROR",
        message: error.message
      });
    }
  });
}

function startProductionServer(port = process.env.PORT || 3100) {
  const server = createProductionServer();
  server.listen(port, () => {
    const address = server.address();
    console.log(`PASS: PRODUCTION_BACKEND_LISTENING :: ${address.port}`);
  });
  return server;
}

if (require.main === module) {
  startProductionServer();
}

module.exports = {
  buildProductionResponse,
  createInMemoryState,
  createProductionServer,
  normalizePath,
  startProductionServer
};