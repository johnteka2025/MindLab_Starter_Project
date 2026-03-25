function exportReport(data) {
    if (!data) throw new Error("STOP: export data missing");

    return JSON.stringify({
        version: "2.0",
        export: data
    });
}

module.exports = { exportReport };
