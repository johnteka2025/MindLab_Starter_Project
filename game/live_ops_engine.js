const fs = require("fs");
const path = require("path");

const configFile = path.join(__dirname, "season_config.json");

function loadConfig() {
    return JSON.parse(fs.readFileSync(configFile, "utf8"));
}

function saveConfig(data) {
    fs.writeFileSync(configFile, JSON.stringify(data, null, 2));
}

function validateSeason(season) {
    if (!season) throw new Error("STOP: season missing");
    if (!season.id) throw new Error("STOP: season id missing");
    if (!season.name) throw new Error("STOP: season name missing");
    if (!Array.isArray(season.content)) throw new Error("STOP: season content missing");
    return true;
}

function getActiveSeason() {
    const data = loadConfig();
    return data.seasons.find(x => x.id === data.activeSeasonId) || null;
}

function setActiveSeason(seasonId) {
    const data = loadConfig();
    const season = data.seasons.find(x => x.id === seasonId);
    if (!season) throw new Error("STOP: active season not found");
    data.activeSeasonId = seasonId;
    saveConfig(data);
}

function addSeason(season) {
    validateSeason(season);
    const data = loadConfig();
    data.seasons.push(season);
    saveConfig(data);
}

module.exports = {
    validateSeason,
    getActiveSeason,
    setActiveSeason,
    addSeason
};
