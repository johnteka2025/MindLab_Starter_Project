"use strict";

const engine = require("./phase17_multiplayer_orchestration_engine.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = engine.main({
        sessionId: "session-300",
        matchId: "match-300",
        hostPlayer: "Maya",
        guestPlayer: "Noah",
        difficulty: "hard",
        category: "science",
        questionCount: 10
    });

    assert(result.ok === true, "orchestration ok mismatch");
    assert(result.orchestrationId === "orch-match-300", "orchestration id mismatch");
    assert(result.sessionId === "session-300", "sessionId mismatch");
    assert(result.matchId === "match-300", "matchId mismatch");
    assert(result.state === "awaiting_players", "state mismatch");
    assert(result.players.length === 2, "player count mismatch");
    assert(result.players[0].name === "Maya", "host player mismatch");
    assert(result.players[1].name === "Noah", "guest player mismatch");
    assert(result.questionCount === 10, "questionCount mismatch");

    console.log("OK PHASE17 MULTIPLAYER ORCHESTRATION SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
