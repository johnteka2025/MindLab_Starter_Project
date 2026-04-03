import { runEngineCycle } from "./mindlab_engine_bridge.js"
import { renderPuzzle } from "./mindlab_renderer.js"

export function runUI(result) {
    const puzzle = runEngineCycle(result)
    return renderPuzzle(puzzle)
}


