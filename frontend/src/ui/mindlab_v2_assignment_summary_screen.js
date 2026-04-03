function loadAssignmentSummaryScreen(data) {
    if (!data) throw new Error("STOP: assignment data missing");

    return {
        screen: "assignment-summary",
        state: "ready",
        assignments: data.assignments || []
    };
}

module.exports = {
    loadAssignmentSummaryScreen
};


