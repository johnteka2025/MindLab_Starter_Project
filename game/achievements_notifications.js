const fs = require("fs");
const path = require("path");

function getUnlockedAchievements() {
    const file = path.join(__dirname, "achievements.json");
    const data = JSON.parse(fs.readFileSync(file, "utf8"));
    return data.achievements
        .filter(x => x.unlocked)
        .map(x => ({
            id: x.id,
            message: `Achievement unlocked: ${x.id}`
        }));
}

module.exports = { getUnlockedAchievements };
