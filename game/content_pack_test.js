const fs = require("fs");
const path = require("path");
const { addPack, getPack } = require("./content_pack_engine");

const dataPath = path.join(__dirname, "content_packs.json");
const backupPath = path.join(__dirname, "content_packs.test.backup.json");

function writeJsonNoBom(filePath, obj) {
    fs.writeFileSync(filePath, JSON.stringify(obj, null, 2));
}

function resetData() {
    writeJsonNoBom(dataPath, {
        version: "1.0",
        packs: []
    });
}

try {
    fs.copyFileSync(dataPath, backupPath);
    resetData();

    addPack({
        id: "pack-001",
        version: "1.0",
        content: ["level1", "level2"]
    });

    const pack = getPack("pack-001");

    if (!pack) throw new Error("STOP: pack missing");
    if (pack.id !== "pack-001") throw new Error("STOP: pack id mismatch");
    if (!Array.isArray(pack.content) || pack.content.length !== 2) {
        throw new Error("STOP: pack content mismatch");
    }

    console.log("OK: content pack test passed");
}
catch (e) {
    console.error(e.message || e);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, dataPath);
        fs.unlinkSync(backupPath);
    }
}