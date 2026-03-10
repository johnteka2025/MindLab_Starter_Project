"use strict";

const express = require("express");
const http = require("http");
const router = require("../src/routes/multiplayerMatch.cjs");

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

    const server = app.listen(8130, "127.0.0.1");

    try {
        const response = await postJson(8130, "/game/multiplayer-match", {
            matchId: "match-100",
            hostPlayer: "Maya",
            guestPlayer: "Noah",
            difficulty: "medium",
            category: "science",
            questionCount: 12
        });

        assert(response.statusCode === 200, "expected 200");
        assert(response.body.ok === true, "expected top-level ok");
        assert(response.body.result.ok === true, "expected result ok");
        assert(response.body.result.matchId === "match-100", "matchId mismatch");
        assert(response.body.result.hostPlayer === "Maya", "hostPlayer mismatch");
        assert(response.body.result.guestPlayer === "Noah", "guestPlayer mismatch");
        assert(response.body.result.playersReady === true, "playersReady mismatch");
        assert(response.body.result.state === "waiting_for_players", "state mismatch");

        console.log("OK ROUTE MULTIPLAYER MATCH SMOKE PASSED");
    }
    finally {
        await new Promise((resolve) => server.close(resolve));
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
