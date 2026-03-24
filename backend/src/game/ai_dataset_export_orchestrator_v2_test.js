const { buildDatasetExport } = require("./ai_dataset_export_orchestrator_v2");

try {
    const dataset = buildDatasetExport([
        {
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
                durationSeconds: 90,
                moves: 12
            }
        }
    ]);

    if (!dataset || !Array.isArray(dataset.records) || dataset.records.length !== 1) {
        throw new Error("STOP: dataset export record count mismatch");
    }

    if (!String(dataset.records[0].anonymousUserId).startsWith("anon_")) {
        throw new Error("STOP: dataset export anonymization mismatch");
    }

    console.log("OK: dataset export orchestrator test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
