const { buildRecommendationResponse } = require("./recommendation_service_v2");

function handleRecommendationRequest(requestBody) {
    if (!requestBody) throw new Error("STOP: request body missing");
    if (!Array.isArray(requestBody.candidatePuzzles) || requestBody.candidatePuzzles.length === 0) {
        throw new Error("STOP: candidatePuzzles missing");
    }

    return buildRecommendationResponse(requestBody.candidatePuzzles, requestBody);
}

module.exports = {
    handleRecommendationRequest
};
