const { loadMindLabV2Experience } = require("./mindlab_v2_ux_flow_controller");

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
        const recommendationScreen = await loadMindLabV2Experience({
            mode: "recommendation",
            candidatePuzzles: [{ id: "puzzle-a" }]
        });

        if (!recommendationScreen || recommendationScreen.recommendedPuzzle.id !== "puzzle-a") {
            throw new Error("STOP: recommendation screen mismatch");
        }

        const generationScreen = await loadMindLabV2Experience({
            mode: "generation",
            payload: {
                userId: "user-001",
                targetSkills: {
                    pattern_recognition: 2
                }
            }
        });

        if (!generationScreen || generationScreen.generatedPuzzle.id !== "generated-puzzle-001") {
            throw new Error("STOP: generation screen mismatch");
        }

        console.log("OK: UX flow controller test passed");
    }
    catch (err) {
        console.error(err.message || err);
        process.exit(1);
    }
})();


