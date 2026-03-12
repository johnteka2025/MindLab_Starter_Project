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
        sessionId: "session-700",
        matchId: "match-700",
        replayFrames: [
            { tick: 1, actor: "Maya", action: "answer", value: "A" },
            { tick: 2, actor: "Noah", action: "answer", value: "B" }
        ],
        finalState: "completed",
        winner: "Maya"
    };

    assertString(payload.sessionId, "sessionId");
    assertString(payload.matchId, "matchId");
    assertString(payload.finalState, "finalState");
    assertString(payload.winner, "winner");
    assertArray(payload.replayFrames, "replayFrames");

    const result = {
        ok: true,
        replayId: "replay-" + payload.matchId,
        sessionId: payload.sessionId,
        matchId: payload.matchId,
        frameCount: payload.replayFrames.length,
        replayFrames: payload.replayFrames.map((frame) => ({
            tick: frame.tick,
            actor: frame.actor,
            action: frame.action,
            value: frame.value
        })),
        finalState: payload.finalState,
        winner: payload.winner,
        replayState: "archived",
        archivedAt: new Date().toISOString()
    };

    console.log(JSON.stringify(result, null, 2));
    return result;
}

module.exports = { main };

if (require.main === module) {
    main();
}
