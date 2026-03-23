const fs = require("fs");
const path = require("path");
const { applySessionResult, getSkillProfile } = require("./user_skill_progression_v2");

const profilePath = path.join(__dirname, "user_skill_profile_v2_schema.json");
const backupPath = path.join(__dirname, "user_skill_profile_v2_schema.test.backup.json");

function resetProfile() {
    fs.writeFileSync(profilePath, JSON.stringify({
        version: "2.0",
        userId: "user-001",
        ageMode: "adults",
        skills: {
            pattern_recognition: 0,
            working_memory: 0,
            logical_reasoning: 0,
            cognitive_flexibility: 0
        },
        history: [],
        lastUpdated: ""
    }, null, 2));
}

try {
    fs.copyFileSync(profilePath, backupPath);
    resetProfile();

    applySessionResult({
        sessionId: "session-001",
        skillDeltas: {
            pattern_recognition: 2,
            logical_reasoning: 1
        }
    });

    const profile = getSkillProfile();

    if (profile.skills.pattern_recognition !== 2) {
        throw new Error("STOP: pattern_recognition mismatch");
    }

    if (profile.skills.logical_reasoning !== 1) {
        throw new Error("STOP: logical_reasoning mismatch");
    }

    if (!Array.isArray(profile.history) || profile.history.length !== 1) {
        throw new Error("STOP: history mismatch");
    }

    console.log("OK: user skill progression test passed");
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
