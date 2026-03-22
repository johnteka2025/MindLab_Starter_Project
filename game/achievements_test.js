const fs = require("fs");
const path = require("path");
const { evaluate } = require("./achievements_engine");

const achievementsPath = path.join(__dirname, "achievements.json");
const backupPath = path.join(__dirname, "achievements.test.backup.json");

function resetData() {
    const seed = {
        achievements: [
            { id: "first_win", condition: "wins >= 1", unlocked: false },
            { id: "ten_wins", condition: "wins >= 10", unlocked: false },
            { id: "hundred_moves", condition: "moves >= 100", unlocked: false },
            { id: "perfect_game", condition: "no_errors", unlocked: false }
        ]
    };
    fs.writeFileSync(achievementsPath, JSON.stringify(seed, null, 2));
}

try {
    fs.copyFileSync(achievementsPath, backupPath);
    resetData();

    evaluate({ wins: 1, moves: 100, errors: 0 });

    const result = JSON.parse(fs.readFileSync(achievementsPath, "utf8"));
    const unlocked = result.achievements.filter(x => x.unlocked).map(x => x.id);

    const expected = ["first_win", "hundred_moves", "perfect_game"];
    const missing = expected.filter(x => !unlocked.includes(x));

    if (missing.length > 0) {
        throw new Error("STOP: missing expected unlocks -> " + missing.join(", "));
    }

    if (unlocked.includes("ten_wins")) {
        throw new Error("STOP: unexpected unlock -> ten_wins");
    }

    console.log("OK: achievements test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, achievementsPath);
        fs.unlinkSync(backupPath);
    }
}
