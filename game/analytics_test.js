const fs = require("fs");
const path = require("path");
const { logEvent, getMetrics, exportReport } = require("./analytics_engine");

const dataPath = path.join(__dirname, "analytics_data.json");
const backupPath = path.join(__dirname, "analytics_data.test.backup.json");

function resetData() {
    fs.writeFileSync(dataPath, JSON.stringify({
        events: [],
        metrics: {
            sessions: 0,
            actions: 0,
            errors: 0
        }
    }, null, 2));
}

try {
    fs.copyFileSync(dataPath, backupPath);
    resetData();

    logEvent("session_start", { id: "session-001" });
    logEvent("action", { action: "move" });
    logEvent("action", { action: "jump" });
    logEvent("error", { code: "E001" });

    const metrics = getMetrics();
    const report = exportReport();

    if (metrics.sessions !== 1) throw new Error("STOP: sessions metric mismatch");
    if (metrics.actions !== 2) throw new Error("STOP: actions metric mismatch");
    if (metrics.errors !== 1) throw new Error("STOP: errors metric mismatch");
    if (report.totalEvents !== 4) throw new Error("STOP: report totalEvents mismatch");

    console.log("OK: analytics test passed");
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
