import { handleUserInput } from "./mindlab_input_handler.js"
import { runUI } from "./mindlab_ui_controller.js"

export function runGame(answer) {
    const result = handleUserInput(answer)
    return runUI(result)
}

