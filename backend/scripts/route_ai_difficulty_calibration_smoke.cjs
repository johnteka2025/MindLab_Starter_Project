"use strict";

const express = require("express");
const http = require("http");
const router = require("../src/routes/aiDifficultyCalibration.cjs");

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
    app.use("/game", router);

    const server = app.listen(8131, "127.0.0.1");

    try {
        const response = await postJson(8131, "/game/ai-difficulty-calibration", {
            playerAccuracy: 90,
            responseTimeMs: 7000
        });

        assert(response.statusCode === 200, "expected 200");
        assert(response.body.ok === true, "expected top-level ok");
        assert(response.body.result.ok === true, "expected result ok");
        assert(response.body.result.recommendedDifficulty === "hard", "difficulty mismatch");

        console.log("OK ROUTE AI DIFFICULTY CALIBRATION SMOKE PASSED");
    }
    finally {
        await new Promise((resolve) => server.close(resolve));
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
