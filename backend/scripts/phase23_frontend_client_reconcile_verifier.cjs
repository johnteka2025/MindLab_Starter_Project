"use strict";

const adapter = require("./phase23_frontend_client_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const questionState = adapter.main({
        sessionId: "session-1001",
        matchId: "match-1001",
        playerName: "Noah",
        route: "/play/session-1001",
        uiState: {
            screen: "question",
            questionIndex: 2,
            selectedAnswer: "C"
        }
    });

    const resultsState = adapter.main({
        sessionId: "session-1002",
        matchId: "match-1002",
        playerName: "Maya",
        route: "/results/session-1002",
        uiState: {
            screen: "results",
            questionIndex: 10,
            selectedAnswer: "B"
        }
    });

    assert(questionState.clientState === "synced", "question clientState mismatch");
    assert(resultsState.clientState === "synced", "results clientState mismatch");
    assert(questionState.uiState.questionIndex === 2, "question index mismatch");
    assert(resultsState.uiState.screen === "results", "results screen mismatch");

    console.log("OK PHASE23 FRONTEND CLIENT RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
