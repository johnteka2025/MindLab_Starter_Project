import { selectNextPuzzle } from "../engine/mindlab_adaptive_engine.js"
import { createInitialState, updateState } from "../engine/mindlab_state_tracker.js"
import { normalizeOutput } from "../engine/mindlab_output_adapter.js"

export function runEngineCycle(result) {
    let state = createInitialState()
    state = updateState(state, result)
    const raw = selectNextPuzzle(state)
    return normalizeOutput(raw)
}
