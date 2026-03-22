const fs = require("fs");
const path = require("path");

const filePath = path.join(__dirname, "content_packs.json");

function load() {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function save(data) {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

function validatePack(pack) {
    if (!pack.id) throw new Error("STOP: pack id missing");
    if (!pack.version) throw new Error("STOP: pack version missing");
    if (!Array.isArray(pack.content)) throw new Error("STOP: content missing");
}

function addPack(pack) {
    validatePack(pack);
    const data = load();
    data.packs.push(pack);
    save(data);
}

function getPack(id) {
    return load().packs.find(p => p.id === id);
}

module.exports = { addPack, getPack, validatePack };
