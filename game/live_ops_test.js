const fs = require("fs");
const path = require("path");
const { validateSeason, getActiveSeason, setActiveSeason, addSeason } = require("./live_ops_engine");

const configPath = path.join(__dirname, "season_config.json");
const backupPath = path.join(__dirname, "season_config.test.backup.json");

function resetConfig() {
    fs.writeFileSync(configPath, JSON.stringify({
        activeSeasonId: "season-001",
        seasons: [
            {
                id: "season-001",
                name: "Starter Season",
                enabled: true,
                content: ["starter-pack", "daily-challenge-a"]
            }
        ]
    }, null, 2));
}

try {
    fs.copyFileSync(configPath, backupPath);
    resetConfig();

    const newSeason = {
        id: "season-002",
        name: "Challenge Season",
        enabled: true,
        content: ["challenge-pack", "daily-challenge-b"]
    };

    validateSeason(newSeason);
    addSeason(newSeason);
    setActiveSeason("season-002");

    const active = getActiveSeason();
    if (!active) throw new Error("STOP: active season missing");
    if (active.id !== "season-002") throw new Error("STOP: active season mismatch");

    console.log("OK: live ops test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, configPath);
        fs.unlinkSync(backupPath);
    }
}
