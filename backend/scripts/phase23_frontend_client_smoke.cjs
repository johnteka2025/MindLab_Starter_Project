"use strict";

const adapter = require("./phase23_frontend_client_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-1000",
        matchId: "match-1000",
        playerName: "Maya",
        route: "/play/session-1000",
        uiState: {
            screen: "question",
            questionIndex: 1,
            selectedAnswer: "A"
        }
    });

    assert(result.ok === true, "client ok mismatch");
    assert(result.clientSyncId === "client-match-1000", "clientSyncId mismatch");
    assert(result.sessionId === "session-1000", "sessionId mismatch");
    assert(result.matchId === "match-1000", "matchId mismatch");
    assert(result.playerName === "Maya", "playerName mismatch");
    assert(result.route === "/play/session-1000", "route mismatch");
    assert(result.uiState.screen === "question", "screen mismatch");
    assert(result.clientState === "synced", "clientState mismatch");

    console.log("OK PHASE23 FRONTEND CLIENT SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
