"use strict";

const express = require("express");
const http = require("http");

const gameSessionRouter = require("../src/routes/gameSession.cjs");
const multiplayerMatchRouter = require("../src/routes/multiplayerMatch.cjs");
const aiDifficultyRouter = require("../src/routes/aiDifficultyCalibration.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function postJson(port, path, payload) {
    return new Promise((resolve, reject) => {
        const body = JSON.stringify(payload);
        const req = http.request({
            hostname: "127.0.0.1",
            port,
            path,
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Content-Length": Buffer.byteLength(body)
            }
        }, (res) => {
            let raw = "";
            res.on("data", (chunk) => { raw += chunk; });
            res.on("end", () => {
                resolve({
                    statusCode: res.statusCode,
                    body: JSON.parse(raw)
                });
            });
        });

        req.on("error", reject);
        req.write(body);
        req.end();
    });
}

async function main() {
    const app = express();
    app.use(express.json());
    app.use("/game", gameSessionRouter);
    app.use("/game", multiplayerMatchRouter);
    app.use("/game", aiDifficultyRouter);

    const server = app.listen(8132, "127.0.0.1");

    try {
        const sessionResponse = await postJson(8132, "/game/game-session", {
            player: "Maya",
            difficulty: "medium",
            question: "Q1"
        });

        assert(sessionResponse.statusCode === 200, "game-session status mismatch");
        assert(sessionResponse.body.ok === true, "game-session top-level ok mismatch");

        const matchResponse = await postJson(8132, "/game/multiplayer-match", {
            matchId: "match-200",
            hostPlayer: "Maya",
            guestPlayer: "Noah",
            difficulty: "hard",
            category: "science",
            questionCount: 12
        });

        assert(matchResponse.statusCode === 200, "multiplayer-match status mismatch");
        assert(matchResponse.body.ok === true, "multiplayer-match top-level ok mismatch");

        const aiResponse = await postJson(8132, "/game/ai-difficulty-calibration", {
            playerAccuracy: 90,
            responseTimeMs: 7000
        });

        assert(aiResponse.statusCode === 200, "ai-difficulty-calibration status mismatch");
        assert(aiResponse.body.ok === true, "ai-difficulty-calibration top-level ok mismatch");
        assert(aiResponse.body.result.recommendedDifficulty === "hard", "ai difficulty mismatch");

        console.log("OK PHASE15 ROUTE REGRESSION SMOKE PASSED");
    }
    finally {
        await new Promise((resolve) => server.close(resolve));
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
