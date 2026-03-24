function generatePuzzle(request) {
    if (!request) throw new Error("STOP: generation request missing");

    return {
        version: "2.0",
        generatedPuzzle: {
            id: "generated-puzzle-001",
            name: "Adaptive Puzzle",
            layout: [["A", "B"], ["C", "D"]],
            skills: [
                { name: "pattern_recognition", weight: Number((request.targetSkills || {}).pattern_recognition || 0) },
                { name: "working_memory", weight: Number((request.targetSkills || {}).working_memory || 0) },
                { name: "logical_reasoning", weight: Number((request.targetSkills || {}).logical_reasoning || 0) },
                { name: "cognitive_flexibility", weight: Number((request.targetSkills || {}).cognitive_flexibility || 0) }
            ],
            difficulty: {
                base: Number(((request.difficulty || {}).base) || 0),
                adaptive: Number(((request.difficulty || {}).adaptive) || 0)
            }
        },
        generatedAt: new Date().toISOString()
    };
}

module.exports = { generatePuzzle };
