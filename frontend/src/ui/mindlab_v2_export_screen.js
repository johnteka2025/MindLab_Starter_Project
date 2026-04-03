function loadExportScreen(report) {
    if (!report) throw new Error("STOP: export report missing");

    return {
        screen: "export",
        state: "ready",
        report
    };
}

module.exports = { loadExportScreen };


