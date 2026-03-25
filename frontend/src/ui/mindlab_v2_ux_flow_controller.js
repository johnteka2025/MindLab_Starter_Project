const { loadRecommendationScreen } = require("./mindlab_v2_recommendation_screen");
const { loadPuzzleGenerationScreen } = require("./mindlab_v2_generation_screen");

async function loadMindLabV2Experience(input) {
    if (!input) throw new Error("STOP: UX flow input missing");

    if (input.mode === "recommendation") {
        return loadRecommendationScreen(input.candidatePuzzles || []);
    }

    if (input.mode === "generation") {
        return loadPuzzleGenerationScreen(input.payload || {});
    }

    throw new Error("STOP: unsupported UX flow mode");
}

module.exports = {
    loadMindLabV2Experience
};
