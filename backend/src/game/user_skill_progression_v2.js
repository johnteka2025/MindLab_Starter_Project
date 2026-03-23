const fs = require("fs");
const path = require("path");

const profileFile = path.join(__dirname, "user_skill_profile_v2_schema.json");

function loadProfile() {
    return JSON.parse(fs.readFileSync(profileFile, "utf8"));
}

function saveProfile(profile) {
    fs.writeFileSync(profileFile, JSON.stringify(profile, null, 2));
}

function ensureProfile(profile) {
    if (!profile) throw new Error("STOP: profile missing");
    if (!profile.skills) throw new Error("STOP: profile skills missing");
    return profile;
}

function applySessionResult(sessionResult) {
    const profile = ensureProfile(loadProfile());

    const deltas = sessionResult && sessionResult.skillDeltas ? sessionResult.skillDeltas : {};
    Object.keys(profile.skills).forEach(skill => {
        const delta = Number(deltas[skill] || 0);
        profile.skills[skill] = Number(profile.skills[skill] || 0) + delta;
    });

    profile.history.push({
        type: "session_result",
        sessionId: sessionResult.sessionId || "",
        skillDeltas: deltas,
        timestamp: new Date().toISOString()
    });

    profile.lastUpdated = new Date().toISOString();
    saveProfile(profile);
    return profile;
}

function getSkillProfile() {
    return ensureProfile(loadProfile());
}

module.exports = {
    applySessionResult,
    getSkillProfile
};
