const { anonymizeUserId, buildDatasetRecord } = require("./ai_dataset_export_v2");

try {
    const anon = anonymizeUserId("user-001");
    if (!anon || !anon.startsWith("anon_")) {
        throw new Error("STOP: anonymizeUserId failed");
    }

    const record = buildDatasetRecord({
        userId: "user-001",
        ageMode: "adults",
        puzzleId: "puzzle-001",
        skillProfile: {
            pattern_recognition: 2,
            working_memory: 1,
            logical_reasoning: 1,
            cognitive_flexibility: 0
        },
        sessionOutcome: {
            success: true,
            durationSeconds: 120,
            moves: 15
        }
    });

    if (record.anonymousUserId === "user-001") {
        throw new Error("STOP: anonymization mismatch");
    }

    if (record.puzzleId !== "puzzle-001") {
        throw new Error("STOP: puzzleId mismatch");
    }

    console.log("OK: dataset export test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
