"use strict";

function assertString(value, fieldName) {
    if (typeof value !== "string" || value.trim() === "") {
        throw new Error(fieldName + " must be a non-empty string");
    }
}

function assertObject(value, fieldName) {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new Error(fieldName + " must be an object");
    }
}

function main(input) {
    const payload = input || {
        sessionId: "session-1000",
        matchId: "match-1000",
        playerName: "Maya",
        route: "/play/session-1000",
        uiState: {
            screen: "question",
            questionIndex: 1,
            selectedAnswer: "A"
        }
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.playerName, "playerName");
    assertString(payload.route, "route");
    assertObject(payload.uiState, "uiState");

    const result = {
        ok: true,
        clientSyncId: "client-" + payload.matchId,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        playerName: payload.playerName,
        route: payload.route,
        uiState: {
            screen: payload.uiState.screen,
            questionIndex: payload.uiState.questionIndex,
            selectedAnswer: payload.uiState.selectedAnswer
        },
        clientState: "synced",
        syncedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
