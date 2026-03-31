import { handleUserInput } from "./mindlab_input_handler.js"
import { runUI } from "./mindlab_ui_controller.js"
import { createProgressRecord, saveProgress } from "../engine/mindlab_progress_store.js"
import { buildScorePayload } from "../engine/mindlab_score_payload.js"

export function runPersistentGame(answer, history = []) {
    const result = handleUserInput(answer)
    const puzzleHtml = runUI(result)
    const record = createProgressRecord(result, puzzleHtml)
    const nextHistory = saveProgress(history, record)
    const payload = buildScorePayload(result, puzzleHtml)

    return {
        result,
        puzzleHtml,
        history: nextHistory,
        payload
    }
}
