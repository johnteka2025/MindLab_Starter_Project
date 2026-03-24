const { handleRecommendationRequest } = require("./recommendation_api_controller_v2");
const { handlePuzzleGenerationRequest } = require("./puzzle_generation_api_controller_v2");
const { persistRecommendation, persistGeneration } = require("./mindlab_v2_persistence_service");

function registerMindLabV2Routes() {
    return {
        "/api/v2/recommendation": (body) => {
            const response = handleRecommendationRequest(body);
            persistRecommendation(response);
            return response;
        },
        "/api/v2/puzzle-generation": (body) => {
            const response = handlePuzzleGenerationRequest(body);
            if (response && response.generation) {
                persistGeneration(response.generation);
            }
            if (response && response.recommendation) {
                persistRecommendation(response.recommendation);
            }
            return response;
        }
    };
}

module.exports = {
    registerMindLabV2Routes
};
