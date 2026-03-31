const { runRecommendationFlow } = require("../services/mindlab_v2_flow_orchestrator");

async function loadRecommendationScreen(candidatePuzzles) {
    const response = await runRecommendationFlow(candidatePuzzles);

    return {
        screen: "recommendation",
        state: "ready",
        recommendedPuzzle: response.recommendedPuzzle || null
    };
}

module.exports = {
    loadRecommendationScreen
};

