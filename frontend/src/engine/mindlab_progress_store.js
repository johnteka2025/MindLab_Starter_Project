export function createProgressRecord(result, puzzleHtml) {
    return {
        timestamp: new Date().toISOString(),
        result,
        puzzleHtml
    }
}

export function saveProgress(history, record) {
    return [...history, record]
}
