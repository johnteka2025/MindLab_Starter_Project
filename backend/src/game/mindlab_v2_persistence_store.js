const fs = require("fs");
const path = require("path");

const storeFile = path.join(__dirname, "mindlab_v2_runtime_store.json");

function loadStore() {
    if (!fs.existsSync(storeFile)) {
        const seed = { recommendations: [], generations: [] };
        fs.writeFileSync(storeFile, JSON.stringify(seed, null, 2));
    }
    return JSON.parse(fs.readFileSync(storeFile, "utf8"));
}

function saveStore(data) {
    fs.writeFileSync(storeFile, JSON.stringify(data, null, 2));
}

function appendRecommendation(item) {
    const data = loadStore();
    data.recommendations.push(item);
    saveStore(data);
    return item;
}

function appendGeneration(item) {
    const data = loadStore();
    data.generations.push(item);
    saveStore(data);
    return item;
}

module.exports = {
    loadStore,
    saveStore,
    appendRecommendation,
    appendGeneration
};
