"use strict";

const adapter = require("./phase19_session_persistence_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-501",
        matchId: "match-501",
        state: "ready_to_start",
        difficulty: "hard",
        category: "history",
        players: [
            { name: "Maya", role: "host", ready: true, connected: true },
            { name: "Noah", role: "guest", ready: true, connected: true }
        ]
    });

    const host = result.players.find((player) => player.role === "host");
    const guest = result.players.find((player) => player.role === "guest");

    assert(result.ok === true, "result ok mismatch");
    assert(result.storageState === "written", "storageState mismatch");
    assert(result.state === "ready_to_start", "state mismatch");
    assert(host && host.ready === true, "host ready mismatch");
    assert(guest && guest.ready === true, "guest ready mismatch");
    assert(host && host.connected === true, "host connected mismatch");
    assert(guest && guest.connected === true, "guest connected mismatch");

    console.log("OK PHASE19 PERSISTENCE RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
