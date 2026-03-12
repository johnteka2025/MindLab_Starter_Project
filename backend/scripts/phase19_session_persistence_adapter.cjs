"use strict";

function assertString(value, fieldName) {
    if (typeof value !== "string" || value.trim() === "") {
        throw new Error(fieldName + " must be a non-empty string");
    }
}

function assertArray(value, fieldName) {
    if (!Array.isArray(value)) {
        throw new Error(fieldName + " must be an array");
    }
}

function main(input) {
    const payload = input || {
        sessionId: "session-500",
        matchId: "match-500",
        state: "awaiting_players",
        difficulty: "medium",
        category: "science",
        players: [
            { name: "Maya", role: "host", ready: false, connected: true },
            { name: "Noah", role: "guest", ready: false, connected: true }
        ]
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.state, "state");
    assertString(payload.difficulty, "difficulty");
    assertString(payload.category, "category");
    assertArray(payload.players, "players");

    const record = {
        ok: true,
        persistenceId: "persist-" + payload.sessionId,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        state: payload.state,
        difficulty: payload.difficulty,
        category: payload.category,
        players: payload.players.map((player) => ({
            name: player.name,
            role: player.role,
            ready: Boolean(player.ready),
            connected: Boolean(player.connected)
        })),
        persistedAt: new Date().toISOString(),
        storageState: "written"
    };

    console.log(JSON.stringify(record, null, 2));
    return record;
}

module.exports = { main };

if (require.main === module) {
    main();
}
