const fs = require("fs");
const path = require("path");

const puzzleDnaFile = path.join(__dirname, "puzzle_dna_v2_schema.json");
const profileFile = path.join(__dirname, "user_skill_profile_v2_schema.json");

function loadPuzzleDna() {
    return JSON.parse(fs.readFileSync(puzzleDnaFile, "utf8"));
}

function loadProfile() {
    return JSON.parse(fs.readFileSync(profileFile, "utf8"));
}

function scorePuzzleForUser(puzzleDna, profile) {
    let score = 0;

    const puzzleSkills = Array.isArray(puzzleDna.skills) ? puzzleDna.skills : [];
    puzzleSkills.forEach(item => {
        const userSkill = Number((profile.skills || {})[item.name] || 0);
        const weight = Number(item.weight || 0);
        score += Math.abs(userSkill - weight);
    });

    const adaptive = Number(((puzzleDna.difficulty || {}).adaptive) || 0);
    return score + adaptive;
}

function recommendNextPuzzle(candidatePuzzles) {
    const profile = loadProfile();

    if (!Array.isArray(candidatePuzzles) || candidatePuzzles.length === 0) {
        throw new Error("STOP: candidate puzzles missing");
    }

    const ranked = candidatePuzzles.map(puzzle => ({
        id: puzzle.id,
        score: scorePuzzleForUser(puzzle, profile)
    })).sort((a, b) => a.score - b.score);

    return ranked[0];
}

function getDefaultPuzzleDna() {
    return loadPuzzleDna();
}

module.exports = {
    recommendNextPuzzle,
    getDefaultPuzzleDna,
    scorePuzzleForUser
};
