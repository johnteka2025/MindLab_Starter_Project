const { orchestrateGenerationAndRecommendation } = require("./puzzle_generation_orchestrator_v2");

function handlePuzzleGenerationRequest(requestBody) {
    if (!requestBody) throw new Error("STOP: request body missing");
    return orchestrateGenerationAndRecommendation(requestBody);
}

module.exports = { handlePuzzleGenerationRequest };
