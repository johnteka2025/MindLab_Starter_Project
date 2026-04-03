const {
    requestRecommendation,
    requestPuzzleGeneration
} = require("./mindlab_v2_client_api");

async function runRecommendationFlow(candidatePuzzles) {
    return requestRecommendation({
        candidatePuzzles
    });
}

async function runPuzzleGenerationFlow(payload) {
    return requestPuzzleGeneration(payload);
}

module.exports = {
    runRecommendationFlow,
    runPuzzleGenerationFlow
};


