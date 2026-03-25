function loadAnalyticsDashboard(data) {
    if (!data) throw new Error("STOP: analytics dashboard data missing");

    return {
        screen: "analytics-dashboard",
        state: "ready",
        metrics: {
            totalSessions: Number(data.totalSessions || 0),
            totalLearners: Number(data.totalLearners || 0),
            avgCompletionRate: Number(data.avgCompletionRate || 0)
        },
        trends: data.trends || []
    };
}

module.exports = {
    loadAnalyticsDashboard
};
