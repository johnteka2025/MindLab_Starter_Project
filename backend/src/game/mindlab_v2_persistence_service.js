const {
    appendRecommendation,
    appendGeneration,
    loadStore
} = require("./mindlab_v2_persistence_store");

function persistRecommendation(data) {
    if (!data) throw new Error("STOP: recommendation data missing");
    return appendRecommendation({
        ...data,
        persistedAt: new Date().toISOString()
    });
}

function persistGeneration(data) {
    if (!data) throw new Error("STOP: generation data missing");
    return appendGeneration({
        ...data,
        persistedAt: new Date().toISOString()
    });
}

function getRuntimeStore() {
    return loadStore();
}

module.exports = {
    persistRecommendation,
    persistGeneration,
    getRuntimeStore
};
