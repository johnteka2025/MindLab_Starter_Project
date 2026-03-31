export function createInitialState() {
    return {
        stage: "K1",
        performance: "neutral",
        history: []
    }
}

export function updateState(state, result) {
    state.history.push(result)

    if (result === "correct") state.performance = "high"
    if (result === "wrong") state.performance = "low"

    return state
}
