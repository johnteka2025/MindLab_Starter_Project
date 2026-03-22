const fs = require("fs");
const path = require("path");

function getAchievementStatusView() {
    const file = path.join(__dirname, "achievements.json");
    const data = JSON.parse(fs.readFileSync(file, "utf8"));

    return data.achievements.map(x => ({
        id: x.id,
        unlocked: x.unlocked
    }));
}

module.exports = { getAchievementStatusView };
