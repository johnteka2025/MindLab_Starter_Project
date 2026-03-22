const fs = require("fs");
const path = require("path");

const dataFile = path.join(__dirname, "analytics_data.json");

function loadData() {
    return JSON.parse(fs.readFileSync(dataFile, "utf8"));
}

function saveData(data) {
    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
}

function logEvent(type, payload = {}) {
    const data = loadData();

    data.events.push({
        type,
        payload,
        timestamp: new Date().toISOString()
    });

    if (type === "session_start") data.metrics.sessions += 1;
    if (type === "action") data.metrics.actions += 1;
    if (type === "error") data.metrics.errors += 1;

    saveData(data);
}

function getMetrics() {
    const data = loadData();
    return data.metrics;
}

function exportReport() {
    const data = loadData();
    return {
        totalEvents: data.events.length,
        sessions: data.metrics.sessions,
        actions: data.metrics.actions,
        errors: data.metrics.errors
    };
}

module.exports = {
    logEvent,
    getMetrics,
    exportReport
};
