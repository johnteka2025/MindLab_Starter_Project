"use strict";

const adapter = require("./phase21_replay_adapter.cjs");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}

function main() {
    const result = adapter.main({
        sessionId: "session-701",
        matchId: "match-701",
        replayFrames: [
            { tick: 1, actor: "Maya", action: "join", value: "host" },
            { tick: 2, actor: "Noah", action: "join", value: "guest" },
            { tick: 3, actor: "Maya", action: "answer", value: "C" }
        ],
        finalState: "completed",
        winner: "Maya"
    });

    assert(result.ok === true, "result ok mismatch");
    assert(result.frameCount === 3, "frameCount mismatch");
    assert(result.replayFrames[0].action === "join", "first frame action mismatch");
    assert(result.replayFrames[2].value === "C", "third frame value mismatch");
    assert(result.winner === "Maya", "winner mismatch");
    assert(result.replayState === "archived", "replayState mismatch");

    console.log("OK PHASE21 REPLAY RECONCILE VERIFIER PASSED");
}

module.exports = { main };

if (require.main === module) {
    main();
}
