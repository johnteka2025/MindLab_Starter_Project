"use strict";

const adapter = require("./phase19_session_persistence_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-500",
        matchId: "match-500",
        state: "awaiting_players",
        difficulty: "medium",
        category: "science",
        players: [
            { name: "Maya", role: "host", ready: false, connected: true },
            { name: "Noah", role: "guest", ready: false, connected: true }
        ]
    });

    assert(result.ok === true, "persistence ok mismatch");
    assert(result.persistenceId === "persist-session-500", "persistenceId mismatch");
    assert(result.sessionId === "session-500", "sessionId mismatch");
    assert(result.matchId === "match-500", "matchId mismatch");
    assert(result.storageState === "written", "storageState mismatch");
    assert(result.players.length === 2, "players length mismatch");

    console.log("OK PHASE19 SESSION PERSISTENCE SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
