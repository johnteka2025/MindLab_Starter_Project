function loadLearnerProgressReview(data) {
    if (!data) throw new Error("STOP: learner progress data missing");

    return {
        screen: "learner-progress-review",
        state: "ready",
        learnerId: data.learnerId || "",
        progress: data.progress || {},
        reports: data.reports || []
    };
}

module.exports = {
    loadLearnerProgressReview
};

