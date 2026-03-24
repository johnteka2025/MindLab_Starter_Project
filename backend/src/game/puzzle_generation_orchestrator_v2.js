const { generatePuzzle } = require("./puzzle_generation_service_v2");
const { buildRecommendationResponse } = require("./recommendation_service_v2");

function orchestrateGenerationAndRecommendation(request) {
    if (!request) throw new Error("STOP: orchestration request missing");

    const generation = generatePuzzle(request);

    const recommendation = buildRecommendationResponse([
        generation.generatedPuzzle
    ], request);

    return {
        version: "2.0",
        generation,
        recommendation,
        generatedAt: new Date().toISOString()
    };
}

module.exports = { orchestrateGenerationAndRecommendation };
