"use strict";

const engine = require("./phase17_multiplayer_orchestration_engine.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = engine.main({
        sessionId: "session-301",
        matchId: "match-301",
        hostPlayer: "Maya",
        guestPlayer: "Noah",
        difficulty: "medium",
        category: "history",
        questionCount: 8
    });

    const host = result.players.find((player) => player.role === "host");
    const guest = result.players.find((player) => player.role === "guest");

    assert(result.ok === true, "result ok mismatch");
    assert(result.state === "awaiting_players", "state mismatch");
    assert(host && host.connected === true, "host connected mismatch");
    assert(guest && guest.connected === true, "guest connected mismatch");
    assert(host && host.ready === false, "host ready mismatch");
    assert(guest && guest.ready === false, "guest ready mismatch");
    assert(result.category === "history", "category mismatch");
    assert(result.difficulty === "medium", "difficulty mismatch");

    console.log("OK PHASE17 SESSION RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
