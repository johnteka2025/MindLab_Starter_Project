function anonymizeUserId(userId) {
    if (!userId) return "";
    return "anon_" + Buffer.from(String(userId)).toString("hex").slice(0, 12);
}

function buildDatasetRecord(input) {
    if (!input) throw new Error("STOP: input missing");
    if (!input.userId) throw new Error("STOP: userId missing");
    if (!input.puzzleId) throw new Error("STOP: puzzleId missing");

    return {
        anonymousUserId: anonymizeUserId(input.userId),
        ageMode: input.ageMode || "",
        puzzleId: input.puzzleId,
        skillProfile: input.skillProfile || {
            pattern_recognition: 0,
            working_memory: 0,
            logical_reasoning: 0,
            cognitive_flexibility: 0
        },
        sessionOutcome: input.sessionOutcome || {
            success: false,
            durationSeconds: 0,
            moves: 0
        }
    };
}

module.exports = {
    anonymizeUserId,
    buildDatasetRecord
};
