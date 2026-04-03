const { loadEducatorReviewDashboard } = require("./mindlab_v2_educator_review_dashboard");
const { loadLearnerProgressReview } = require("./mindlab_v2_learner_progress_review");
const { loadAssignmentSummaryScreen } = require("./mindlab_v2_assignment_summary_screen");
const { loadExportReviewScreen } = require("./mindlab_v2_export_review_screen");

try {
    const dashboard = loadEducatorReviewDashboard({
        learners: [{ id: "learner-001" }],
        assignments: [{ id: "assign-001" }],
        exports: [{ id: "export-001" }]
    });

    if (!dashboard || dashboard.learners.length !== 1) {
        throw new Error("STOP: educator dashboard mismatch");
    }

    const progress = loadLearnerProgressReview({
        learnerId: "learner-001",
        progress: { completed: 5 },
        reports: [{ id: "weekly-001" }]
    });

    if (!progress || progress.learnerId !== "learner-001") {
        throw new Error("STOP: learner progress review mismatch");
    }

    const assignment = loadAssignmentSummaryScreen({
        assignments: [{ id: "assign-001" }]
    });

    if (!assignment || assignment.assignments.length !== 1) {
        throw new Error("STOP: assignment summary mismatch");
    }

    const exportReview = loadExportReviewScreen({
        exports: [{ id: "export-001" }]
    });

    if (!exportReview || exportReview.exports.length !== 1) {
        throw new Error("STOP: export review mismatch");
    }

    console.log("OK: admin / educator integration test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}


