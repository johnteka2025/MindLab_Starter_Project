const fs = require("fs");
const path = require("path");
const { registerMindLabV2Routes } = require("./mindlab_v2_route_registry");

const storePath = path.join(__dirname, "mindlab_v2_runtime_store.json");
const backupPath = path.join(__dirname, "mindlab_v2_runtime_store.test.backup.json");
const profilePath = path.join(__dirname, "user_skill_profile_v2_schema.json");
const profileBackupPath = path.join(__dirname, "user_skill_profile_v2_schema.route.backup.json");

function resetStore() {
    fs.writeFileSync(storePath, JSON.stringify({
        recommendations: [],
        generations: []
    }, null, 2));
}

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
    if (fs.existsSync(storePath)) fs.copyFileSync(storePath, backupPath);
    if (fs.existsSync(profilePath)) fs.copyFileSync(profilePath, profileBackupPath);

    resetStore();
    resetProfile();

    const routes = registerMindLabV2Routes();

    const recommendationResponse = routes["/api/v2/recommendation"]({
        candidatePuzzles: [
            {
                id: "puzzle-a",
                skills: [
                    { name: "pattern_recognition", weight: 2 },
                    { name: "working_memory", weight: 1 }
                ],
                difficulty: { adaptive: 0 }
            }
        ]
    });

    const generationResponse = routes["/api/v2/puzzle-generation"]({
        userId: "user-001",
        ageMode: "adults",
        targetSkills: {
            pattern_recognition: 2,
            working_memory: 1,
            logical_reasoning: 1,
            cognitive_flexibility: 0
        },
        difficulty: {
            base: 1,
            adaptive: 1
        },
        constraints: {
            maxMoves: 20,
            sessionLengthMinutes: 10
        }
    });

    const store = JSON.parse(fs.readFileSync(storePath, "utf8"));

    if (!recommendationResponse || !recommendationResponse.recommendedPuzzle) {
        throw new Error("STOP: recommendation route response missing");
    }

    if (!generationResponse || !generationResponse.generation || !generationResponse.recommendation) {
        throw new Error("STOP: generation route response missing");
    }

    if (!Array.isArray(store.recommendations) || store.recommendations.length < 2) {
        throw new Error("STOP: persisted recommendations mismatch");
    }

    if (!Array.isArray(store.generations) || store.generations.length !== 1) {
        throw new Error("STOP: persisted generations mismatch");
    }

    console.log("OK: route registry test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, storePath);
        fs.unlinkSync(backupPath);
    }
    if (fs.existsSync(profileBackupPath)) {
        fs.copyFileSync(profileBackupPath, profilePath);
        fs.unlinkSync(profileBackupPath);
    }
}
