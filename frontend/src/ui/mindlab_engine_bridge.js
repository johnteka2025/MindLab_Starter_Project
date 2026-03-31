import { selectNextPuzzle } from "../engine/mindlab_adaptive_engine.js"
import { createInitialState, updateState } from "../engine/mindlab_state_tracker.js"

export function runEngineCycle(result) {
    let state = createInitialState()
    state = updateState(state, result)
    return selectNextPuzzle(state)
}
