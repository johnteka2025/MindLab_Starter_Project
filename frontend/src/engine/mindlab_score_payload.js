export function buildScorePayload(result, puzzleHtml) {
    return {
        result,
        puzzleHtml,
        score: result === "correct" ? 1 : 0
    }
}

