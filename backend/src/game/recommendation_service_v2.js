function scorePuzzleForRequest(puzzle, request) {
    const targetSkills = (request && request.targetSkills) ? request.targetSkills : {};
    const puzzleSkills = Array.isArray(puzzle.skills) ? puzzle.skills : [];

    let score = 0;
    puzzleSkills.forEach(item => {
        const target = Number(targetSkills[item.name] || 0);
        const weight = Number(item.weight || 0);
        score += Math.abs(target - weight);
    });

    const adaptive = Number((((puzzle || {}).difficulty || {}).adaptive) || 0);
    return score + adaptive;
}

function buildRecommendationResponse(candidatePuzzles, request) {
    if (!Array.isArray(candidatePuzzles) || candidatePuzzles.length === 0) {
        throw new Error("STOP: candidate puzzles missing");
    }

    const ranked = candidatePuzzles.map(puzzle => ({
        id: puzzle.id,
        score: scorePuzzleForRequest(puzzle, request || {})
    })).sort((a, b) => a.score - b.score);

    return {
        version: "2.0",
        recommendedPuzzle: ranked[0],
        generatedAt: new Date().toISOString()
    };
}

module.exports = {
    buildRecommendationResponse,
    scorePuzzleForRequest
};
