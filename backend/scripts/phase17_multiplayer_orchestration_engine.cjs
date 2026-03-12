"use strict";

function assertString(value, fieldName) {
    if (typeof value !== "string" || value.trim() === "") {
        throw new Error(fieldName + " must be a non-empty string");
    }
}

function assertPositiveInteger(value, fieldName) {
    if (!Number.isInteger(value) || value <= 0) {
        throw new Error(fieldName + " must be a positive integer");
    }
}

function buildPlayerSlot(playerName, role) {
    return {
        name: playerName,
        role,
        ready: false,
        connected: true
    };
}

function main(input) {
    const payload = input || {
        sessionId: "session-300",
        matchId: "match-300",
        hostPlayer: "Maya",
        guestPlayer: "Noah",
        difficulty: "hard",
        category: "science",
        questionCount: 10
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.hostPlayer, "hostPlayer");
    assertString(payload.guestPlayer, "guestPlayer");
    assertString(payload.difficulty, "difficulty");
    assertString(payload.category, "category");
    assertPositiveInteger(payload.questionCount, "questionCount");

    const result = {
        ok: true,
        orchestrationId: "orch-" + payload.matchId,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        state: "awaiting_players",
        difficulty: payload.difficulty,
        category: payload.category,
        questionCount: payload.questionCount,
        players: [
            buildPlayerSlot(payload.hostPlayer, "host"),
            buildPlayerSlot(payload.guestPlayer, "guest")
        ],
        createdAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
