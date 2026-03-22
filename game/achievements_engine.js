const fs = require("fs");

function loadAchievements() {
    return JSON.parse(fs.readFileSync("game/achievements.json"));
}

function saveAchievements(data) {
    fs.writeFileSync("game/achievements.json", JSON.stringify(data, null, 2));
}

function evaluate(stats) {
    const data = loadAchievements();

    data.achievements.forEach(a => {
        if (!a.unlocked) {
            if (a.id === "first_win" && stats.wins >= 1) a.unlocked = true;
            if (a.id === "ten_wins" && stats.wins >= 10) a.unlocked = true;
            if (a.id === "hundred_moves" && stats.moves >= 100) a.unlocked = true;
            if (a.id === "perfect_game" && stats.errors === 0) a.unlocked = true;
        }
    });

    saveAchievements(data);
}

module.exports = { evaluate };
