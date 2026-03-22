const fs = require("fs");
const path = require("path");
const { validatePuzzle, createPuzzle, getPuzzle } = require("./puzzle_editor_engine");

const dataPath = path.join(__dirname, "puzzle_data.json");
const backupPath = path.join(__dirname, "puzzle_data.test.backup.json");

function resetData() {
    fs.writeFileSync(dataPath, JSON.stringify({ puzzles: [] }, null, 2));
}

try {
    fs.copyFileSync(dataPath, backupPath);
    resetData();

    const puzzle = {
        id: "puzzle-001",
        name: "Starter Puzzle",
        layout: [["A", "B"], ["C", "D"]]
    };

    validatePuzzle(puzzle);
    createPuzzle(puzzle);

    const loaded = getPuzzle("puzzle-001");
    if (!loaded) {
        throw new Error("STOP: puzzle not found after create");
    }

    if (loaded.name !== "Starter Puzzle") {
        throw new Error("STOP: puzzle name mismatch");
    }

    console.log("OK: puzzle editor test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, dataPath);
        fs.unlinkSync(backupPath);
    }
}
