function loadExportReviewScreen(data) {
    if (!data) throw new Error("STOP: export review data missing");

    return {
        screen: "export-review",
        state: "ready",
        exports: data.exports || []
    };
}

module.exports = {
    loadExportReviewScreen
};

