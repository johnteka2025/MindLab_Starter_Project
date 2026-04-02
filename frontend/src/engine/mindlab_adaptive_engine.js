export function selectNextPuzzle(state) {
    const { stage, performance } = state

    if (!stage) return null

    if (performance === "high") return stage + "_advance"
    if (performance === "low") return stage + "_repeat"

    return stage + "_standard"
}


