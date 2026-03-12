"use strict";

const adapter = require("./phase21_replay_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-700",
        matchId: "match-700",
        replayFrames: [
            { tick: 1, actor: "Maya", action: "answer", value: "A" },
            { tick: 2, actor: "Noah", action: "answer", value: "B" }
        ],
        finalState: "completed",
        winner: "Maya"
    });

    assert(result.ok === true, "replay ok mismatch");
    assert(result.replayId === "replay-match-700", "replayId mismatch");
    assert(result.sessionId === "session-700", "sessionId mismatch");
    assert(result.matchId === "match-700", "matchId mismatch");
    assert(result.frameCount === 2, "frameCount mismatch");
    assert(result.finalState === "completed", "finalState mismatch");
    assert(result.winner === "Maya", "winner mismatch");
    assert(result.replayState === "archived", "replayState mismatch");

    console.log("OK PHASE21 REPLAY SMOKE PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
