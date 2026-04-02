const { runPuzzleGenerationFlow } = require("../services/mindlab_v2_flow_orchestrator");

async function loadPuzzleGenerationScreen(payload) {
    const response = await runPuzzleGenerationFlow(payload);

    return {
        screen: "generation",
        state: "ready",
        generatedPuzzle: response.generation ? response.generation.generatedPuzzle : null,
        recommendedPuzzle: response.recommendation ? response.recommendation.recommendedPuzzle : null
    };
}

module.exports = {
    loadPuzzleGenerationScreen
};


