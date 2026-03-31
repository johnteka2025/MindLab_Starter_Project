import { selectNextPuzzle } from "../engine/mindlab_adaptive_engine"
import { createInitialState, updateState } from "../engine/mindlab_state_tracker"

export function runEngineCycle(result) {
    let state = createInitialState()
    state = updateState(state, result)
    return selectNextPuzzle(state)
}
