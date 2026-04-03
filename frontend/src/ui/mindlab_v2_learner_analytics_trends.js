function loadLearnerAnalyticsTrends(data) {
    if (!data) throw new Error("STOP: learner analytics trend data missing");

    return {
        screen: "learner-analytics-trends",
        state: "ready",
        learnerId: data.learnerId || "",
        weeklyTrend: data.weeklyTrend || [],
        monthlyTrend: data.monthlyTrend || []
    };
}

module.exports = {
    loadLearnerAnalyticsTrends
};


