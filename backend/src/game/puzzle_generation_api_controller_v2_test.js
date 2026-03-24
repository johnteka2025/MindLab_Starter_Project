const { handlePuzzleGenerationRequest } = require("./puzzle_generation_api_controller_v2");

try {
    const response = handlePuzzleGenerationRequest({
        userId: "user-001",
        ageMode: "adults",
        targetSkills: {
            pattern_recognition: 2,
            working_memory: 1,
            logical_reasoning: 1,
            cognitive_flexibility: 0
        },
        difficulty: {
            base: 1,
            adaptive: 1
        },
        constraints: {
            maxMoves: 20,
            sessionLengthMinutes: 10
        }
    });

    if (!response || !response.generation || !response.recommendation) {
        throw new Error("STOP: response structure mismatch");
    }

    if (response.recommendation.recommendedPuzzle.id !== "generated-puzzle-001") {
        throw new Error("STOP: recommendation output mismatch");
    }

    console.log("OK: puzzle generation API controller test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
