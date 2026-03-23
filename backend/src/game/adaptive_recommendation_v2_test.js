const fs = require("fs");
const path = require("path");
const { recommendNextPuzzle } = require("./adaptive_recommendation_v2");

const profilePath = path.join(__dirname, "user_skill_profile_v2_schema.json");
const backupPath = path.join(__dirname, "user_skill_profile_v2_schema.rec.backup.json");

function resetProfile() {
    fs.writeFileSync(profilePath, JSON.stringify({
        version: "2.0",
        userId: "user-001",
        ageMode: "adults",
        skills: {
            pattern_recognition: 2,
            working_memory: 1,
            logical_reasoning: 1,
            cognitive_flexibility: 0
        },
        history: [],
        lastUpdated: ""
    }, null, 2));
}

try {
    fs.copyFileSync(profilePath, backupPath);
    resetProfile();

    const result = recommendNextPuzzle([
        {
            id: "puzzle-a",
            skills: [
                { name: "pattern_recognition", weight: 2 },
                { name: "working_memory", weight: 1 }
            ],
            difficulty: { adaptive: 0 }
        },
        {
            id: "puzzle-b",
            skills: [
                { name: "pattern_recognition", weight: 5 },
                { name: "working_memory", weight: 4 }
            ],
            difficulty: { adaptive: 2 }
        }
    ]);

    if (!result) {
        throw new Error("STOP: recommendation result missing");
    }

    if (result.id !== "puzzle-a") {
        throw new Error("STOP: recommendation mismatch");
    }

    console.log("OK: adaptive recommendation test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, profilePath);
        fs.unlinkSync(backupPath);
    }
}
