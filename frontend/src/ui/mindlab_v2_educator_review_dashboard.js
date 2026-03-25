function loadEducatorReviewDashboard(data) {
    if (!data) throw new Error("STOP: educator review data missing");

    return {
        screen: "educator-review-dashboard",
        state: "ready",
        learners: data.learners || [],
        assignments: data.assignments || [],
        exports: data.exports || []
    };
}

module.exports = {
    loadEducatorReviewDashboard
};
