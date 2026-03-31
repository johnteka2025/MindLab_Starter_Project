import { runPersistentGame } from "./mindlab_persistent_game_runner.js"

let history = []

const inputs = ["correct", "wrong", "invalid"]

inputs.forEach(input => {
    const output = runPersistentGame(input, history)
    history = output.history
    console.log("RESULT:", output.result)
    console.log("HISTORY_COUNT:", output.history.length)
    console.log("SCORE:", output.payload.score)
})
