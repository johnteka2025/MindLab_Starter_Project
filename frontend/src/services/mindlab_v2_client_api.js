async function postJson(url, body) {
    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    });

    if (!response.ok) {
        throw new Error(`STOP: request failed -> ${response.status}`);
    }

    return response.json();
}

async function requestRecommendation(payload) {
    return postJson("/api/v2/recommendation", payload);
}

async function requestPuzzleGeneration(payload) {
    return postJson("/api/v2/puzzle-generation", payload);
}

module.exports = {
    postJson,
    requestRecommendation,
    requestPuzzleGeneration
};

