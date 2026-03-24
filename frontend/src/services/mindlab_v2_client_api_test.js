const {
    requestRecommendation,
    requestPuzzleGeneration
} = require("./mindlab_v2_client_api");

global.fetch = async (url, options) => {
    const body = JSON.parse(options.body);

    if (url === "/api/v2/recommendation") {
        return {
            ok: true,
            json: async () => ({
                version: "2.0",
                recommendedPuzzle: {
                    id: (body.candidatePuzzles || [])[0].id,
                    score: 0
                }
            })
        };
    }

    if (url === "/api/v2/puzzle-generation") {
        return {
            ok: true,
            json: async () => ({
                version: "2.0",
                generation: {
                    generatedPuzzle: {
                        id: "generated-puzzle-001"
                    }
                },
                recommendation: {
                    recommendedPuzzle: {
                        id: "generated-puzzle-001",
                        score: 0
                    }
                }
            })
        };
    }

    return {
        ok: false,
        status: 404,
        json: async () => ({})
    };
};

(async () => {
    try {
        const recommendation = await requestRecommendation({
            candidatePuzzles: [{ id: "puzzle-a" }]
        });

        if (!recommendation || recommendation.recommendedPuzzle.id !== "puzzle-a") {
            throw new Error("STOP: recommendation client mismatch");
        }

        const generation = await requestPuzzleGeneration({
            userId: "user-001",
            targetSkills: {
                pattern_recognition: 2
            }
        });

        if (!generation || generation.generation.generatedPuzzle.id !== "generated-puzzle-001") {
            throw new Error("STOP: puzzle generation client mismatch");
        }

        console.log("OK: client API integration test passed");
    }
    catch (err) {
        console.error(err.message || err);
        process.exit(1);
    }
})();
