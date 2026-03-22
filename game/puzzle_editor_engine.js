const fs = require("fs");
const path = require("path");

const dataFile = path.join(__dirname, "puzzle_data.json");

function loadData() {
    return JSON.parse(fs.readFileSync(dataFile, "utf8"));
}

function saveData(data) {
    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
}

function validatePuzzle(puzzle) {
    if (!puzzle) throw new Error("STOP: puzzle missing");
    if (!puzzle.id) throw new Error("STOP: puzzle id missing");
    if (!puzzle.name) throw new Error("STOP: puzzle name missing");
    if (!Array.isArray(puzzle.layout)) throw new Error("STOP: puzzle layout missing");
    return true;
}

function createPuzzle(puzzle) {
    validatePuzzle(puzzle);
    const data = loadData();
    data.puzzles.push(puzzle);
    saveData(data);
}

function getPuzzle(id) {
    const data = loadData();
    return data.puzzles.find(x => x.id === id) || null;
}

module.exports = {
    validatePuzzle,
    createPuzzle,
    getPuzzle
};
